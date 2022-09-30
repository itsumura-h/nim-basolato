import std/asyncdispatch
import std/mimetypes
export asyncdispatch
export mimetypes

when defined(httpbeast):
  import ./basolato/beta/core/route
  import ./basolato/beta/core/server
elif defined(httpx):
  import ./basolato/beta/core/route
  import ./basolato/beta/core/server
else:
  import ./basolato/std/core/route
  import ./basolato/std/core/server

export route
export server
