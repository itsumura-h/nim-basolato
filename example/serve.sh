function serve () {
  killall main
  nim c main
  ./main &
}

serve
inotifywait -m --exclude "([^ni].$|[^m]$)" ./ \
-r -e CLOSE_WRITE -e CREATE -e DELETE  | \
while read line; do
  echo ${line}
  serve
done
