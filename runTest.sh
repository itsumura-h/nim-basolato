nimble install -y
cd /root/project/tests/server
nim c main
nohup ./main 1>/dev/null 2>/dev/null &
cd /root/project/
nimble test

killall main
rm tests/server/main
rm tests/server/db.sqlite3
rm tests/server/session.db
rm tests/server/session.db.bak
rm -fr tests/server/logs/*

find tests/ -type f ! -name "*.*" -delete 2>/dev/null
