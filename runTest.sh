set -eux

trap finally EXIT

function finally {
  # delete files
  pkill main
  rm server/main || true
  rm server/db.sqlite3 || true
  rm server/session.db || true
  rm session.db || true
  rm -fr logs || true
  rm -fr server/logs || true
  rm .env || true
  find ./ -type f ! -name "*.*" -delete 2> /dev/null
}

nim -v
nimble -v

# run server
nimble remove basolato -iy || true
nimble install -y
cd /application/tests/server
nim c --mm:orc --threads:off -d:ssl --parallelBuild:0 main
nohup ./main > /dev/null 2>&1 &

# run test
cd /application/tests
touch server/session.db
touch server/db.sqlite3
cp server/.env ./
rm -fr ./testresults
testament p "test_*.nim"
testament p "*/test_*.nim"
