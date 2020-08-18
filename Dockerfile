ARG ELIXIR_VERSION=1.9.4

ARG MIX_ENV="prod"
ARG APP_DIR="/opt/app"

## get magnetissimo source
#	the workdir in the build container is non-empty, this
#	is the easiest/laziest way to get the code there
#
FROM moonbuggy2000/fetcher:latest as fetcher

ARG APP_DIR
ARG ROOT_DIR

RUN git clone --depth 1 https://github.com/moonbuggy/magnetissimo.git ${APP_DIR} \
	&& rm -rf ${APP_DIR}\.git*


## build magnetissimo
#
FROM bitwalker/alpine-elixir-phoenix:${ELIXIR_VERSION} as builder

ARG MIX_ENV
ARG	APP_DIR

WORKDIR ${APP_DIR}

COPY --from=fetcher ${APP_DIR} ${APP_DIR}
COPY magnetissimo/ ${APP_DIR}/

#RUN mix local.hex --force \
#	&& mix local.rebar --force

RUN sed -E 's|(@edge.*)|@edge http://dl-cdn.alpinelinux.org/alpine/edge/main|' -i /etc/apk/repositories \
	&& sed -E 's|gzip:\s([a-zA-Z]*)(.?)|gzip: true\2|' -i ${APP_DIR}/apps/magnetissimo_web/lib/magnetissimo_web/endpoint.ex \
	&& mix deps.get --only prod \
	&& mix deps.compile

RUN cd ${APP_DIR}/apps/magnetissimo_web/assets \
	&& npm install \
	&& node node_modules/webpack/bin/webpack.js --mode production

RUN	cd ${APP_DIR}/apps/magnetissimo_web \
	&& mix phx.digest
	
RUN mix compile


## build final container
#
FROM bitwalker/alpine-elixir:${ELIXIR_VERSION}

ARG MIX_ENV
ARG APP_DIR

ENV MIX_ENV=${MIX_ENV} \
	APP_DIR=${APP_DIR}

WORKDIR ${APP_DIR}

#RUN mix local.hex --force \
#	&& mix local.rebar --force

COPY --from=builder ${APP_DIR}/mix.* ${APP_DIR}/
COPY --from=builder ${APP_DIR}/_build ${APP_DIR}/_build
COPY --from=builder ${APP_DIR}/apps ${APP_DIR}/apps
COPY --from=builder ${APP_DIR}/config ${APP_DIR}/config
COPY --from=builder ${APP_DIR}/deps ${APP_DIR}/deps
COPY entrypoint.sh /

EXPOSE 4000

#VOLUME ${APP_DIR}/config

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --start-period=10s --timeout=10s \
	CMD wget --quiet --tries=1 --spider http://127.0.0.1:4000/healthcheck && echo 'okay' || exit 1