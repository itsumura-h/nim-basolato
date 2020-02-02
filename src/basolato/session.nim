import
  httpcore, json, os, random, std/sha1, oids,
  strformat, strutils, tables, times
# 3rd party
import jester/private/utils
import flatdb
# framework
import base
import private
import cookie

type
  SessionDb* = ref object
    conn: FlatDb
    token: string

  SessionType* = enum
    File
    Redis

  Session* = ref object
    db: SessionDb

const
  SESSION_TIME = getEnv("SESSION_TIME").string.parseInt
  SESSION_DB_FILE = getEnv("SESSION_DB").string
  IS_SESSION_MEMORY = getEnv("IS_SESSION_MEMORY").string.parseBool

# ========= Flat DB ==================
proc newSessionDb*(token=""):SessionDb =
  let db = newFlatDb(SESSION_DB_FILE, IS_SESSION_MEMORY)
  discard db.load()
  if token.len > 0:
    return SessionDb(conn: db, token:token)
  else:
    let token = db.append(newJObject())
    return SessionDb(conn: db, token:token)

proc token*(this:SessionDb): string =
  this.token

proc set*(this:SessionDb, key, value:string):SessionDb =
  let db = this.conn
  db[this.token][key] = %value
  db.flush()
  return this

proc get*(this:SessionDb, key:string): string =
  let db = this.conn
  return db[this.token].getOrDefault(key).getStr()

proc delete*(this:SessionDb, key:string):SessionDb =
  let db = this.conn
  let row = db[this.token]
  if row.hasKey(key):
    row.delete(key)
    db.flush()
  return this

proc destroy*(this:SessionDb) =
  this.conn.delete(this.token)


# ========= Session ==================
# proc newSession*(typ=File, token=""):Session =
#   if typ == File:
#     return Session(db:newSessionDb(token))

# proc db*(this:Session):SessionDb =
#   this.db

# proc rundStr*():string =
#   randomize()
#   for _ in .. 50:
#     add(result, char(rand(int('A')..int('z'))))

# proc setCookie*(this:Session, expires: DateTime): string =
#   newCookie("token", this.token,
#             format(expires.utc, "ddd',' dd MMM yyyy HH:mm:ss 'GMT'"),
#             Lax, false, false, "", "")

# proc sessionStart*(uid:string):Session =
#   randomize()
#   let token = rundStr().secureHash()
#   # insert db
#   var db = newFlatDb()
#   discard db.load()
#   db.append(%*{
#     "token": $token, "created_at": $(getTime().toUnix()), "uid": uid
#   })
#   return Session(token: $token)

# proc sessionStart*(): Session =
#   randomize()
#   let token = rundStr().secureHash()
#   var db = newFlatDb()
#   discard db.load()
#   db.append(%*{
#     "token": $token, "created_at": $(getTime().toUnix())
#   })
#   return Session(token: $token)

# proc sessionDestroy*(token:string) =
#   var db = newFlatDb()
#   discard db.load()
#   let session = db.queryOne(equal("token", token))
#   let id = session["_id"].getStr
#   db.delete(id)

# proc add*(this:Session, key:string, val:string):Session =
#   var db = newFlatDb()
#   discard db.load()
#   let session = db.queryOne(equal("token", this.token))
#   if isNil(session):
#     raise newException(Error403, "CSRF verification failed.")
#   # check timeout
#   let generatedAt = session["created_at"].getStr.parseInt
#   if getTime().toUnix() > generatedAt + SESSION_TIME:
#     raise newException(Error403, "Session Timeout.")
#   # add
#   session[key] = %val
#   db.flush()
#   return this

# proc removeSession*(token:string) =
#   var db = newFlatDb()
#   discard db.load()
#   let session = db.queryOne(equal("token", token))
#   let id = session["_id"].getStr
#   db.delete id

# proc getSession*(request:Request, key:string): string =
#   let token = request.getCookie("token")
#   var db = newFlatDb()
#   let session = db.queryOne(equal("token", token))
#   result = ""
#   if session.hasKey(key):
#     result = session[key].getStr
