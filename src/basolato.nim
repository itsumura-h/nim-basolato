import std/asyncdispatch; export asyncdispatch
import std/mimetypes; export mimetypes

when defined(httpbeast):
  import ./basolato/beta/core/route; export route
  import ./basolato/beta/core/server; export server
elif defined(httpx):
  import ./basolato/beta/core/route; export route
  import ./basolato/beta/core/server; export server
else:
  import ./basolato/std/core/route; export route
  import ./basolato/std/core/server; export server
