#!/bin/sh

# current directory needs where this script is located
cd "$(dirname "$0")"

UWSGI_VIRTUALENV=/app/venv \
UWSGI_WSGI_FILE=/app/src/wsgi.py \
UWSGI_MASTER=1 \
UWSGI_WORKERS=2 \
UWSGI_THREADS=8 \
UWSGI_UID=nobody \
UWSGI_GID=nobody \
UWSGI_LAZY_APPS=1 \
UWSGI_WSGI_ENV_BEHAVIOR=holy \
	/app/venv/bin/uwsgi \
		--enable-threads \
		--http-auto-chunked \
		--http-keepalive \
		--socket=/app/socket/uwsgi.sock &

