import ../../../../../models/dto/follow_button/follow_button_dto


type FollowButtonViewModel*  = object
  userName*:string
  isFollowed*:bool
  followerCount*:int
  oobSwap*:bool

proc new*(_:type FollowButtonViewModel, dto:FollowButtonDto, oobSwap:bool):FollowButtonViewModel =
  return FollowButtonViewModel(
    userName:dto.userName,
    isFollowed:dto.isFollowed,
    followerCount: dto.followerCount,
    oobSwap:oobSwap,
  )
