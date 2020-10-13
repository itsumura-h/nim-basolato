import prologue
import allographer/query_builder

import random
# const
randomize()
const range1_10000 = 1..10000


proc hello*(ctx: Context) {.async.} =
  resp "<h1>Hello, Prologue!</h1>"

proc db*(ctx: Context) {.async, gcsafe.} =
  let i = rand(range1_10000)
  let response = rdb().table("world").asyncFind(i)
  # let response = rdb().table("world").find(i)
  resp $(await response)
