discard """
  cmd: "nim c -r $file"
"""

import std/unittest
include ../src/basolato/std/core/request


block:
  let requestPath = "/name/john/id/1"
  let routePath = "/name/{name:str}/id/{id:int}"
  let params = getUrlParams(requestPath, routePath)
  check params.getStr("name") == "john"
  check params.getInt("id") == 1

block:
  var requestPath = "/name/john/id/1"
  var routePath = "/name/{name:str}/id/{id:int}"
  check isMatchUrl(requestPath, routePath) == true

  requestPath = "/name"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/name"
  routePath = "/{name:str}"
  check isMatchUrl(requestPath, routePath) == true

  requestPath = "/john"
  routePath = "/{name:str}"
  check isMatchUrl(requestPath, routePath) == true

  requestPath = "/1"
  routePath = "/{name:str}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/1"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == true

  requestPath = "/"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/1/abc"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/1/1"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/john/1"
  routePath = "/{name:str}"
  check isMatchUrl(requestPath, routePath) == false

  requestPath = "/john?age=20"
  routePath = "/{name:str}"
  check isMatchUrl(requestPath, routePath) == true

  requestPath = "/1?name=john"
  routePath = "/{id:int}"
  check isMatchUrl(requestPath, routePath) == true
