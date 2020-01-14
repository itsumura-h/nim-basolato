import os, json, times, strutils
import jester, flatdb
import base, routing
from controller import render

export
  base, jester, Response, render

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost:
    let params = request.params
    let token = params["_token"]
    # check token is valid
    var db = newFlatDb("session.db", false)
    discard db.load()
    let session = db.queryOne(equal("token", token))
    if isNil(session):
      raise newException(CsrfError, "CSRF verification failed.")
    # check timeout
    let timeoutSecound = getEnv("session.time").parseInt
    let generatedAt = session["generated_at"].getStr.parseInt
    if getTime().toUnix() > generatedAt + timeoutSecound:
      raise newException(CsrfError, "Session Timeout.")
    # delete token from session
    let id = session["_id"].getStr
    db.delete(id)
