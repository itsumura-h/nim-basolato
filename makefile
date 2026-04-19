exec:
	docker compose start
	docker compose exec app-ubuntu bash

stop:
	docker compose stop

main:
	git switch main
	git pull
	git pull -p

diff:
	git diff --cached > .diff

reinstall:
	-nimble uninstall basolato -iy
	nimble install -y

clean:
	rm -f ~/.nimble/nimbledata2.json
	rm -fr ~/.nimble/pkgs2/*
	rm -fr ~/.nimble/pkgcache/*
	nimble install -y -d