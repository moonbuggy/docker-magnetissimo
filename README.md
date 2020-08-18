# Docker Magnetissimo
[Sergiotapia's Magnetissimo](https://github.com/sergiotapia/magnetissimo) (with [modification](https://github.com/moonbuggy/magnetissimo)) in a Docker container.

## Usage
```
docker run --name magnetissimo -d -p 4000:4000 moonbuggy2000/magnetissimo:latest
```

The web UI will be available at `http://<hostname-or-IP>:4000/`.

### Requirements
Magnetissimo requires a PostgreSQL database to store data in. Database configuration is via the environment or by persisting `/opt/app/config/prod.exs`.

### Environment variables
Environment variables can be specified with the `-e` flag or in `docker-compose.yml`. Available environment variables are:

* ``DB_HOST``        - database server hostname or IP
* ``DB_PORT``        - database server port
* ``DB_NAME``        - database name
* ``DB_USER``        - database user name
* ``DB_PASS``        - database user password
* ``MAG_LOG_LEVEL``  - global log level (accepts: `debug`, `info`, `warn`, `error` default: `info`)
* ``MAG_WEB_LOG``    - hides web logs by setting them to `debug` (accepts: `true`, `false` default: `true`)

## Links
GitHub: https://github.com/moonbuggy/docker-magnetissimo

Docker Hub: https://hub.docker.com/r/moonbuggy2000/magnetissimo