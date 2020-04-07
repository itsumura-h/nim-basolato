import strutils
import basolato/model

type User = ref object of Model

proc newUser*():User =
  return User.newModel()
