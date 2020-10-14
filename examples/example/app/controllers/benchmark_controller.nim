import random
import ../../../../src/basolato/controller
import allographer/query_builder

const range1_10000 = 1..10000

proc db*(request:Request, params:Params):Future[Response] {.async.} =
  let i = rand(range1_10000)
  let response = await rdb().table("world").asyncFind(i)
  return render(response)
