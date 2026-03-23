import ../../../../models/dto/follow_button/follow_button_dto


type FollowButtonViewModel*  = object
  userId*: string
  userName*: string
  isFollowed*: bool
  followerCount*: int

proc new*(_:type FollowButtonViewModel, dto:FollowButtonDto):FollowButtonViewModel =
  return FollowButtonViewModel(
    userId:dto.userId,
    userName:dto.userName,
    isFollowed:dto.isFollowed,
    followerCount: dto.followerCount,
  )
