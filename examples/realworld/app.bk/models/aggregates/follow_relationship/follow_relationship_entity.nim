import ./user_entity

type FollowRelationship* = object
  user*:User
  follower*:User


proc new*(_:type FollowRelationship, user, follower:User):FollowRelationship =
  return FollowRelationship(
    user:user,
    follower:follower
  )
