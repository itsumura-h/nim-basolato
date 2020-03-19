import jester, os

routes:
  get "/":
    sleep 10000
    resp "root"
  get "/a":
    resp "a"