import ../../vo/user_id

type Follow* = object
  userId*: UserId
  followerId*: UserId

proc new*(_: type Follow, userId: UserId, followerId: UserId): Follow =
  return Follow(
    userId: userId,
    followerId: followerId,
  )
