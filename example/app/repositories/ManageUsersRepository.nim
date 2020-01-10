import json
import allographer/query_builder

type ManegeUserRepository* = ref object


proc newManegeUserRepository*():ManegeUserRepository =
  return ManegeUserRepository()

proc index*(this:ManegeUserRepository): seq[JsonNode] =
  return RDB().table("users").get()

proc show*(this:ManegeUserRepository, id: int): JsonNode =
  return RDB().table("users").find(id)
