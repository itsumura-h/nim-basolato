type FollowButtonDto* = object
  userId*: string
  userName*: string
  isFollowed*: bool
  followerCount*: int

proc new*(_:type FollowButtonDto, userId: string, userName:string, isFollowed: bool, followerCount: int): FollowButtonDto =
  return FollowButtonDto(
    userId: userId,
    userName: userName,
    isFollowed: isFollowed,
    followerCount: followerCount,
  )
