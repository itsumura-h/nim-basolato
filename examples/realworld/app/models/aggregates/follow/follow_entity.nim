import ../../vo/user_id

type Follow* = object
  userId*:UserId

proc new*(userId:UserId):Follow =
  return Follow(userId: userId)
