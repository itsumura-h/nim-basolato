exec:
	docker compose up -d
	docker compose exec app-ubuntu bash

stop:
	docker compose stop

diff:
	git diff --cached > .diff

reinstall:
	-nimble uninstall basolato -iy
	nimble install -y
