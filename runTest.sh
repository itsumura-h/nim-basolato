set -eux

nim -v
nimble -v

# run server
nimble install -y
cd /root/project/tests/server
nim c --mm:orc --threads:off -d:ssl --parallelBuild:0 main
nohup ./main > /dev/null 2>&1 &

# run test
cd /root/project/tests
touch server/session.db
touch server/db.sqlite3
cp server/.env ./
rm -fr ./testresults
testament p "test_*.nim" || true
testament p "*/test_*.nim" || true

# delete files
pkill main
rm server/main
rm server/db.sqlite3
rm server/session.db
rm -fr logs
rm -fr server/logs
rm .env
find ./ -type f ! -name "*.*" -delete 2> /dev/null
