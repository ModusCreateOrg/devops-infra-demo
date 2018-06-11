PWD=$(shell pwd)
SHELL=/bin/bash
web:
	docker run -i -t  \
		--env-file <(grep ^export ../env.sh | cut -c8-) \
		--mount type=bind,source="$(PWD)",target=/app \
		hashicorp/packer:light \
		validate app/machines/web-server.json
	docker run -i -t  \
		--env-file <(grep ^export ../env.sh | cut -c8-) \
		--mount type=bind,source="$(PWD)",target=/app \
		hashicorp/packer:light \
		build app/machines/web-server.json
all: web
