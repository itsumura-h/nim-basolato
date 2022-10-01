import std/os
import std/options
import std/asyncdispatch
import std/json
import std/random
import std/strutils
import std/streams
import std/parsecfg
import httpx
import allographer/connection
import allographer/query_builder
import ./database


randomize()

proc main() =
  proc onRequest(req: Request): Future[void] {.gcsafe, async.} =
    if req.httpMethod == some(HttpGet):
      case req.path.get()
      of "/json":
        const data = $(%*{"message": "Hello, World!"})
        req.send(Http200, data)
      of "/plaintext":
        const data = "Hello, World!"
        const headers = "Content-Type: text/plain"
        req.send(Http200, data, headers)
      of "/sleep":
        sleepAsync(10000).await
        req.send(Http200, "sleep")
      of "/db":
        let countNum = 500
        var response = newSeq[JsonNode](countNum)
        var getFutures = newSeq[Future[seq[string]]](countNum)
        var updateFutures = newSeq[Future[void]](countNum)
        for i in 1..countNum:
          let index = rand(1..10000)
          let number = rand(1..10000)
          getFutures[i-1] = rdb.table("World").select("id", "randomNumber").findPlain(index)
          updateFutures[i-1] = rdb
                              .table("World")
                              .where("id", "=", index)
                              .update(%*{"randomNumber": number})
          response[i-1] = %*{"id":index, "randomNumber": number}

        try:
          discard await all(getFutures)
          await all(updateFutures)
        except:
          discard
        req.send(Http200, $response)
      of "/updates":
        let countNum = 100
        var response = newSeq[JsonNode](countNum)
        var getFutures = newSeq[Future[seq[string]]](countNum)
        var updateFutures = newSeq[Future[void]](countNum)
        for i in 1..countNum:
          let index = rand(1..10000)
          let number = rand(1..10000)
          getFutures[i-1] = rdb.table("World").select("id", "randomNumber").findPlain(index)
          updateFutures[i-1] = rdb
                              .table("World")
                              .where("id", "=", index)
                              .update(%*{"randomNumber": number})
          response[i-1] = %*{"id":index, "randomNumber": number}

        try:
          discard await all(getFutures)
          await all(updateFutures)
        except:
          discard
        req.send(Http200, $response)

      else:
        req.send(Http404)

  let settings = initSettings(port=Port(5000))
  run(onRequest, settings)

main()
