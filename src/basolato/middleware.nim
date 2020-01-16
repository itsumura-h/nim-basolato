import os, json, times, strutils
import jester except redirect
import flatdb
import base, routing
from controller import render, redirect, errorRedirect

# from jester
export jester except redirect
# from base
export base, Response
# from controller
export render, controller.redirect, errorRedirect


proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or
        request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or
        request.reqMethod == HttpDelete:
    # key not found
    if not request.params.contains("_token"):
      raise newException(CsrfError, "CSRF verification failed.")
    # check token is valid
    let token = request.params["_token"]
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
