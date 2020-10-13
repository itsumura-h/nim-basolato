import asynchttpserver, asyncdispatch, random, json
import allographer/query_builder
# const
randomize()
const range1_10000 = 1..10000

proc cb(req: Request) {.async.} =
  let i = rand(range1_10000)
  let response = await rdb().table("world").asyncFind(i)
  let header = newHttpHeaders()
  header.add("Content-type", "application/json; charset=utf-8")
  await req.respond(Http200, $response, header)

proc main =
  let server = newAsyncHttpServer()
  waitFor server.serve(Port(5000), cb)

main()
