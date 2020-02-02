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
  SessionDb = ref object
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
proc newSession*(token="", typ=File):Session =
  if typ == File:
    return Session(db:newSessionDb(token))

proc db*(this:Session):SessionDb =
  this.db

proc set*(this:Session, key, value:string):Session =
  discard this.db.set(key, value)
  return this

proc get*(this:Session, key:string):string =
  this.db.get(key)

proc delete*(this:Session, key:string): Session =
  discard this.db.delete(key)
  return this

proc destroy*(this:Session) =
  this.db.destroy()
