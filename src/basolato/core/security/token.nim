import times, strutils
import encrypt

type Token* = ref object
  token:string


proc newToken*(token=""):Token =
  if token.len > 0:
    return Token(token:token)
  var token = $(getTime().toUnix().int())
  token = token.encryptCtr()
  return Token(token:token)

func getToken*(self:Token):string =
  return self.token

proc toTimestamp*(self:Token): int =
  return self.getToken().decryptCtr().parseInt()