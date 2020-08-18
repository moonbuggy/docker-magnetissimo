#!/bin/sh

cd ${APP_DIR}

if [ ! -z ${MAG_WEB_LOG+set} ]; then
	do_log=$(echo $MAG_WEB_LOG | tr [A-Z] [a-z])
	case $do_log in
		true|on|yes)
			log_level="info"
			;;
		*)
			log_level="debug"
			;;
	esac
	
	log_string="@default_level \"${log_level}\""
	grep -q "${log_string}" ${APP_DIR}/apps/magnetissimo_web/lib/magnetissimo_web/logger.ex \
		|| sed -E "s|(@default_level\s+)(.*)|${log_string}|" -i ${APP_DIR}/apps/magnetissimo_web/lib/magnetissimo_web/logger.ex
fi

mix compile

mix ecto.create
mix ecto.migrate

mix phx.server
