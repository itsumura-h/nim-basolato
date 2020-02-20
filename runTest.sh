nimble install -y
nim c tests/server/main
./tests/server/main > /dev/null &
nimble test

killall main
