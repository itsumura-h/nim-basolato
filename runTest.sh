nimble install -y
nim c -d:release tests/server/main
cd /home/www/tests/server
nohup ./main > /dev/null &
cd /home/www/
nimble test

killall main
rm tests/server/main
rm tests/server/db.sqlite3
rm -fr tests/server/logs/*
