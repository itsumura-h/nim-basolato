set -eux

nim -v
nimble -v

# run server
nimble install -y
cd /root/project/tests/server
#nim c main
ducere build
nohup ./main > /dev/null 2>&1 &

# run test
cd /root/project/
touch tests/server/session.db
touch tests/server/db.sqlite3
cp tests/server/.env ./
rm -fr ./testresults
testament p "tests/test_*.nim"

# delete files
pkill main
rm tests/server/main
rm tests/server/db.sqlite3
rm tests/server/session.db
rm tests/server/session.db.bak
rm -fr tests/server/logs/*
rm .env
find tests/ -type f ! -name "*.*" -delete 2> /dev/null
