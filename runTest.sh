# nimble install -y
# cd /root/project/tests/server
# nim c main
# nohup ./main > /dev/null 2>&1 &
# cd /root/project/
# touch tests/server/session.db
# nimble test

# killall main
# rm tests/server/main
# rm tests/server/db.sqlite3
# rm tests/server/session.db
# rm tests/server/session.db.bak
# rm -fr tests/server/logs/*

# find tests/ -type f ! -name "*.*" -delete 2>/dev/null

set -eux

# run server
nimble install -y
cd /root/project/tests/server
nim c main
nohup ./main > /dev/null 2>&1 &

# run test
cd /root/project/
touch tests/server/session.db
touch tests/server/db.sqlite3
cp tests/server/.env ./
cp tests/server/.env.local ./
rm -fr ./testresults
testament p "tests/test_*.nim"
testament html

# delete files
killall main
rm tests/server/main
rm tests/server/db.sqlite3
rm tests/server/session.db
rm tests/server/session.db.bak
rm -fr tests/server/logs/*
rm .env .env.local
find tests/ -type f ! -name "*.*" -delete 2> /dev/null
