import os, options, asyncdispatch, json, random, strutils, streams, parsecfg

import httpbeast
import allographer/connection
import allographer/query_builder
# import ./database
randomize()

proc main() =
  for f in walkDir(getCurrentDir()):
    if f.path.split("/")[^1] == ".env":
      let path = getCurrentDir() / ".env"
      var f = newFileStream(path, fmRead)
      echo("httpbeast uses config file '", path, "'")
      var p: CfgParser
      open(p, f, path)
      while true:
        var e = next(p)
        case e.kind
        of cfgEof: break
        of cfgKeyValuePair: putEnv(e.key, e.value)
        else: discard
      break

  let rdb = dbopen(
    PostgreSQL, # SQLite3 or MySQL or MariaDB or PostgreSQL
    getEnv("DB_DATABASE"),
    getEnv("DB_USER"),
    getEnv("DB_PASSWORD"),
    getEnv("DB_HOST"),
    getEnv("DB_PORT").parseInt,
    getEnv("DB_MAX_CONNECTION").parseInt,
    getEnv("DB_TIMEOUT").parseInt,
    getEnv("LOG_IS_DISPLAY").parseBool,
    getEnv("LOG_IS_FILE").parseBool,
    getEnv("LOG_DIR"),
  )
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
        # var countNum =
        #   try:
        #     params.getInt("queries")
        #     req.pa
        #   except:
        #     1
        # if countNum < 1:
        #   countNum = 1
        # elif countNum > 500:
        #   countNum = 500
        var countNum = 500

        var proc1 = newSeq[Future[seq[string]]](countNum)
        var proc2 = newSeq[Future[void]](countNum)
        let response = newJArray()
        for n in 1..countNum:
          let i = rand(1..10000)
          let newRandomNumber = rand(1..10000)
          proc1[n-1] = rdb.table("World").findPlain(i)
          proc2[n-1] = rdb.table("World").where("id", "=", i).update(%*{"randomnumber": newRandomNumber})
          response.add(%*{"id":i, "randomNumber": newRandomNumber})

        discard all(proc1).await
        all(proc2).await
        req.send(Http200, $response)

      else:
        req.send(Http404)

  let settings = initSettings(port=Port(5000))
  run(onRequest, settings)

main()
