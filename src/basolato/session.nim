import
  httpcore, json, os, random, std/sha1,
  strformat, strutils, tables, times
# 3rd party
import jester/private/utils
import flatdb
# framework
import base
import private
import cookie

type
  SessionType = enum
    File
    Redis

  SessionBb* = ref object
    conn: FlatDb

  Session* = ref object
    token*: string
    cookie*: tuple[key, value:string]

const
  SESSION_TIME = getEnv("SESSION_TIME").string.parseInt
  SESSION_DB = getEnv("SESSION_DB").string
  IS_SESSION_MEMORY = getEnv("IS_SESSION_MEMORY").string.parseBool

# ========= Flat DB ==================
proc newSessionDb*(): SessionBb =
  var db = newFlatDb(SESSION_DB, IS_SESSION_MEMORY)
  discard db.load()
  return SessionBb(conn: db)

proc get*(this:SessionBb, request:Request, key:string): string =
  let token = request.getCookie("token")
  var db = newSessionDb().conn
  let flat = db.queryOne(equal("token", token))
  result = ""
  if flat.hasKey(key):
    result = flat[key].getStr

proc set*(this:SessionBb, request:Request, key, value:string):SessionBb =
  let token = request.getCookie("token")
  var db = newSessionDb().conn
  let flat = db.queryOne(equal("token", token))
  flat[key] = %value
  db.flush()
  return this

proc delete*(this:SessionBb, request:Request, key:string): SessionBb =
  let token = request.getCookie("token")
  var db = newSessionDb().conn
  let flat = db.queryOne(equal("token", token))


proc destroy*()


# ========= session DB ==================
proc newSessionDb(typ=File): Session =
  return Session()


proc rundStr*():string =
  randomize()
  for _ in .. 50:
    add(result, char(rand(int('A')..int('z'))))

proc setCookie*(this:Session, expires: DateTime): string =
  newCookie("token", this.token,
            format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
            Lax, false, false, "", "")

proc sessionStart*(uid:string):Session =
  randomize()
  let token = rundStr().secureHash()
  # insert db
  var db = initFlatDb()
  discard db.load()
  db.append(%*{
    "token": $token, "created_at": $(getTime().toUnix()), "uid": uid
  })
  return Session(token: $token)

proc sessionStart*(): Session =
  randomize()
  let token = rundStr().secureHash()
  var db = initFlatDb()
  discard db.load()
  db.append(%*{
    "token": $token, "created_at": $(getTime().toUnix())
  })
  return Session(token: $token)

proc sessionDestroy*(token:string) =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", token))
  let id = session["_id"].getStr
  db.delete(id)

proc add*(this:Session, key:string, val:string):Session =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", this.token))
  if isNil(session):
    raise newException(Error403, "CSRF verification failed.")
  # check timeout
  let generatedAt = session["created_at"].getStr.parseInt
  if getTime().toUnix() > generatedAt + SESSION_TIME:
    raise newException(Error403, "Session Timeout.")
  # add
  session[key] = %val
  db.flush()
  return this

proc removeSession*(token:string) =
  var db = initFlatDb()
  discard db.load()
  let session = db.queryOne(equal("token", token))
  let id = session["_id"].getStr
  db.delete id

proc getSession*(request:Request, key:string): string =
  let token = request.getCookie("token")
  var db = initFlatDb()
  let session = db.queryOne(equal("token", token))
  result = ""
  if session.hasKey(key):
    result = session[key].getStr
