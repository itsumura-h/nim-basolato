import std/asyncdispatch
import std/cgi
import std/db_postgres
import std/json
import std/options
import std/random
import std/strutils
import std/strtabs
import std/uri
import httpbeast


randomize()

let rdb = open("postgreDb", "user", "pass", "database")

proc main() =
  proc onRequest(req: Request): Future[void] {.gcsafe, async.} =
    let url = req.path.get().parseUri()
    if req.httpMethod == some(HttpGet):
      case url.path
      of "/json":
        const data = $(%*{"message": "Hello, World!"})
        req.send(Http200, data)
      of "/plaintext":
        const data = "Hello, World!"
        const headers = "Content-Type: text/plain"
        req.send(Http200, data, headers)
      of "/db":
        let i = rand(1..10000)
        let res = rdb.getRow(sql"""SELECT * FROM "World" WHERE id = ? LIMIT 1""", i)
        let response = %*{"id": res[0].parseInt, "randomNumber": res[1].parseInt}
        req.send(Http200, $response)
      of "/updates":
        let queryObj = readData(url.query)
        var count = 1
        try:
            count = clamp(parseInt(queryObj["queries"]), 1, 500)
        except KeyError, ValueError:
            count = 1
        except:
            req.send(Http502, "Something is wrong")

        let response = newJArray()
        var futures = newSeq[Future[void]](count)
        for n in 1..count:
          let i = rand(1..10000)
          let newRandomNumber = rand(1..10000)
          futures[n-1] = (proc():Future[void] {.async.} =
            discard rdb.getRow(sql""" SELECT * FROM "World" WHERE id = ? LIMIT 1 """, i)
            rdb.exec(sql""" UPDATE "World" SET randomnumber = ? WHERE id = ? """, newRandomNumber, i)
          )()
          response.add(%*{"id":i, "randomNumber": newRandomNumber})
        all(futures).await
        req.send($response)

      else:
        req.send(Http404)

  let settings = initSettings(port=Port(5000))
  run(onRequest, settings)

main()
