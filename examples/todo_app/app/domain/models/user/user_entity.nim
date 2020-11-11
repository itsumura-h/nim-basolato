import ../value_objects


type User* = ref object

proc newUser*():User =
  return User()
