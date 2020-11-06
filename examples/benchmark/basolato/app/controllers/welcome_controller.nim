import random
# framework
import ../../../../../src/basolato/controller
import ../../../../../src/basolato/core/base
# view
import ../../resources/pages/welcome_view
import allographer/query_builder
# const
randomize()
const range1_10000 = 1..10000


proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let i = rand(range1_10000)
  let response = await rdb().table("World").asyncFind(i)
  return render(response)
