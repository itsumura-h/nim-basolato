import json, tables
import jester
import BaseClass

export jester, BaseClass


template route*(r:Response) =
  var newHeaders = r.headers
  case r.responseType:
  of String:
    newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    resp r.status, newHeaders, r.bodyString
  of Json:
    newHeaders.add(("Content-Type", "application/json"))
    resp r.status, newHeaders, $(r.bodyJson)

# =============================================================================

proc joinHeader(t1, t2:openArray[tuple[key, value: string]]):seq[tuple[key, value: string]] =
  ## join t1 and t2. t2 can override t1 if both have same key
  ##
  ## .. code-block:: nim
  ##    var t1 = [("key1", "val1"),("key2", "val2")]
  ##
  ##    var t2 = [("key1", "val1++"),("key3", "val3")]
  ##
  ##    var t3 = [
  ##      ("key1", "val1++"),
  ##      ("key2", "val2"),
  ##      ("key3", "val3"),
  ##    ]
  ##
  var t1_1 = t1.toOrderedTable
  let t2_1 = t2.toOrderedTable
  for key, val in t2_1.pairs:
    t1_1[key] = val
  var t3: seq[tuple[key, value:string]]
  for key, val in t1_1.pairs:
    t3.add((key, val))
  return t3


template route*(r:Response,
                middleareHeaders:openArray[tuple[key, value: string]]) =
  var newHeaders = joinHeader(middleareHeaders, r.headers)
  case r.responseType:
  of String:
    newHeaders.add(("Content-Type", "text/html;charset=utf-8"))
    resp r.status, newHeaders, r.bodyString
  of Json:
    newHeaders.add(("Content-Type", "application/json"))
    resp r.status, newHeaders, $(r.bodyJson)



#[

template route*(r:Response, headers:openArray[tuple[key, value: string]]) =
  case r.responseType:
  of String:
    resp r.status, headers, r.bodyString
  of Json:
    var newHeaders = headers
    newHeaders.add(
      ("Content-Type", "application/json")
    )
    resp r.status, newHeaders, $(r.bodyJson)
  of Nil:
    echo getCurrentExceptionMsg()

]#
