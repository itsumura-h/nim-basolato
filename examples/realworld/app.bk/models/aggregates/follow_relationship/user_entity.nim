import ../../vo/user_id

type User* = object
  id*:UserId

proc new*(_:type User, id:UserId): User =
  return User(id:id)
