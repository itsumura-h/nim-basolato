import times, strutils, json, random, strformat, std/sha1
# 3rd party
import jester/private/utils
# framework
import base, private, session, cookie

type
  Auth* = ref object
    isLogin*: bool
    token*: string
    uid*: string
    session_id*: string
    info*: Table[string, string]

proc newAuth*(request:Request):Auth =
  let token = request.getCookie("_token")
  if token.len > 0:
    return Auth(
      isLogin: true,
      token: token
    )



# proc csrfToken*(auth:Auth):string =
#   # insert db
#   if auth.isLogin:
#     var db = initFlatDb()
#     discard db.load()
#     let session = db.queryOne(equal("token", auth.token))
#     session["created_at"] = %($(getTime().toUnix()))
#     return &"""<input type="hidden" name="_token" value="{auth.token}">"""
#   else:
#     randomize()
#     let token = rundStr().secureHash()
#     var db = initFlatDb()
#     discard db.load()
#     db.append(%*{
#       "token": $token, "created_at": $(getTime().toUnix())
#     })
#     return &"""<input type="hidden" name="_token" value="{token}">"""


# proc checkCsrfToken*(request:Request, excTyp=Exception, msg="") =
#   if request.reqMethod == HttpPost or
#         request.reqMethod == HttpPut or
#         request.reqMethod == HttpPatch or
#         request.reqMethod == HttpDelete:
#     var msg = msg
#     # key not found
#     if not request.params.contains("_token"):
#       if msg == "": msg = "CSRF verification failed."
#       raise newException(excTyp, msg)
#     # check token is valid
#     let token = request.params["_token"]
#     var db = initFlatDb()
#     discard db.load()
#     let session = db.queryOne(equal("token", token))
#     if isNil(session):
#       if msg == "": msg = "CSRF verification failed."
#       raise newException(excTyp, msg)
#     # check timeout
#     let loginAt = session["created_at"].getStr.parseInt
#     if getTime().toUnix() > loginAt + SESSION_TIME:
#       # delete token from session
#       let id = session["_id"].getStr
#       db.delete(id)
#       if msg == "": msg = "Session Timeout."
#       raise newException(excTyp, msg)
#     # update login time
#     session["created_at"] = %($(getTime().toUnix()))
#     # delete onetime session
#     if not session.hasKey("uid"):
#       let id = session["_id"].getStr
#       db.delete(id)
#     db.flush()

# proc checkCookieToken*(request:Request) =
#   if request.reqMethod == HttpGet and not request.path.contains("."):
#     let token = request.getCookie("token")
#     if token.len > 0:
#       var db = initFlatDb()
#       discard db.load()
#       let session = db.queryOne(equal("token", token))
#       if isNil(session):
#         raise newException(Exception, "CSRF verification failed.")
#       # check timeout
#       let loginAt = session["created_at"].getStr.parseInt
#       if getTime().toUnix() > loginAt + SESSION_TIME:
#         # delete token from session
#         let id = session["_id"].getStr
#         db.delete(id)
#         raise newException(Exception, "Session Timeout.")
#       # uppdate last login
#       session["created_at"] = %($(getTime().toUnix()))
#       db.flush()



# proc initAuth*(request:Request): Auth =
#   let token = request.getCookie("token")
#   var db = initFlatDb()
#   discard db.load()
#   var info = initTable[string, string]()
#   let session = db.queryOne(equal("token", token))
#   if session == nil:
#     return Auth(isLogin: false)
#   for key, val in session.pairs:
#     info[key] = val.get
#   return Auth(
#     isLogin: true,
#     token: token,
#     uid: $session["uid"].getInt,
#     info: info,
#   )

# proc login(uid:string): Auth =
#   let session = sessionStart(uid)



# proc destroy*(this:Auth) =
#   var db = initFlatDb()
#   discard db.load()
#   let session = db.queryOne(equal("token", this.token))
#   let id = session["_id"].getStr
#   db.delete(id)
