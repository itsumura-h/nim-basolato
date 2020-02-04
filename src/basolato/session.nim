import
  httpcore, json, os, strutils, tables
import flatdb
# framework
import base
import private
import encrypt

type
  SessionDb = ref object
    conn: FlatDb
    token: string

  SessionType* = enum
    File
    Redis

  Session* = ref object
    db: SessionDb


# ========= Flat DB ==================
proc newSessionDb*(token=""):SessionDb =
  let db = newFlatDb(SESSION_DB_PATH, IS_SESSION_MEMORY)
  discard db.load()
  if token.len > 0:
    return SessionDb(conn: db, token:token)
  else:
    let token = db.append(newJObject())
    return SessionDb(conn: db, token:token)

proc getToken*(this:SessionDb): string =
  this.token.encrypt()

proc set*(this:SessionDb, key, value:string):SessionDb =
  let db = this.conn
  db[this.token][key] = %value
  db.flush()
  return this

proc get*(this:SessionDb, key:string): string =
  let db = this.conn
  return db[this.token].getOrDefault(key).getStr("")

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

proc getToken*(this:Session):string =
  this.db.getToken()

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
