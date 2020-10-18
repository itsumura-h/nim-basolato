import options, asyncdispatch, json, random

import httpbeast
import allographer/query_builder
randomize()

proc main() {.async.} =
  proc onRequest(req: Request): Future[void] {.async.} =
    if req.httpMethod == some(HttpGet):
      case req.path.get()
      of "/json":
        const data = $(%*{"message": "Hello, World!"})
        req.send(Http200, data)
      of "/plaintext":
        const data = "Hello, World!"
        const headers = "Content-Type: text/plain"
        req.send(Http200, data, headers)
      of "/db":
        let countNum = 500
        var response = newSeq[JsonNode](countNum)
        var getFutures = newSeq[Future[Row]](countNum)
        var updateFutures = newSeq[Future[void]](countNum)
        for i in 1..countNum:
          let index = rand(1..10000)
          let number = rand(1..10000)
          getFutures[i-1] = rdb().table("World").select("id", "randomNumber").asyncFindPlain(index)
          updateFutures[i-1] = rdb()
                              .table("World")
                              .where("id", "=", index)
                              .asyncUpdate(%*{"randomNumber": number})
          response[i-1] = %*{"id":index, "randomNumber": number}

        try:
          discard await all(getFutures)
          await all(updateFutures)
        except:
          discard
        req.send(Http200, $response)
      else:
        req.send(Http404)

  let settings = initSettings(Port(5000), "", 3)
  run(onRequest, settings)

waitFor main()
