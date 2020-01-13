import os, json, times, strutils
import jester, flatdb
import base, routing
from controller import render

export
  jester, Response, render

type CsrfError* = object of Exception

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or request.reqMethod == HttpDelete:
    let params = request.params
    let token = params["_token"]
    # check token is valid
    var db = newFlatDb("session.db", false)
    discard db.load()
    let session = db.queryOne(equal("token", token))
    if isNil(session):
      # return render(Http403, "CSRF verification failed.")
      raise newException(CsrfError, "CSRF verification failed.")
    # cheeck timeout
    let timeoutSecound = getEnv("session.time").parseInt
    echo timeoutSecound
    let generatedAt = session["generated_at"].getStr.parseInt
    if getTime().toUnix() > generatedAt + timeoutSecound:
      # return render(Http403, "Session Timeout.")
      raise newException(CsrfError, "Session Timeout.")
    # delete token from session
    let id = session["_id"].getStr
    db.delete(id)
