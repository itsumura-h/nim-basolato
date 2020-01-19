import os, json, times, strutils, strformat, macros
# 3rd party
import jester except redirect
import flatdb
# self
import base, routing
from controller import render, redirect, errorRedirect

# from jester
export jester except redirect
# from base
export base, Response
# from controller
export render, controller.redirect, errorRedirect

const SESSION_TIME = getEnv("SESSION_TIME").string.parseInt

proc checkCsrfToken*(request:Request) =
  if request.reqMethod == HttpPost or
        request.reqMethod == HttpPut or
        request.reqMethod == HttpPatch or
        request.reqMethod == HttpDelete:
    # key not found
    if not request.params.contains("_token"):
      raise newException(Error403, "CSRF verification failed.")
    # check token is valid
    let token = request.params["_token"]
    var db = newFlatDb("session.db", false)
    discard db.load()
    let session = db.queryOne(equal("token", token))
    if isNil(session):
      raise newException(Error403, "CSRF verification failed.")
    # check timeout
    let generatedAt = session["generated_at"].getStr.parseInt
    if getTime().toUnix() > generatedAt + SESSION_TIME:
      raise newException(Error403, "Session Timeout.")
    # delete token from session
    let id = session["_id"].getStr
    db.delete(id)

