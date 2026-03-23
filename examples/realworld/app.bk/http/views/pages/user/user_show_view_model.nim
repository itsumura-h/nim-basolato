import ../../../../models/dto/user/user_dto
import ../../../../models/dto/follow_button/follow_button_dto
import ../../islands/follow_button/follow_button_view_model


type User*  = object
  id*:string
  name*:string
  bio*:string
  image*:string
  isSelf*:bool

proc new*(_:type User, id:string, name:string, bio:string, image:string, isSelf:bool):User =
  return User(
    id:id,
    name:name,
    bio:bio,
    image:image,
    isSelf:isSelf,
  )


type UserShowViewModel*  = object
  user*:User
  followButtonViewModel*:FollowButtonViewModel
  loadFavorites*:bool
  hasPage*:bool
  page*:int

proc new*(
  _:type UserShowViewModel,
  dto:UserDto,
  followButtonDto:FollowButtonDto,
  isSelf:bool,
  loadFavorites:bool,
  hasPage=false,
  page=0
):UserShowViewModel =
  let user = User.new(
    dto.id,
    dto.name,
    dto.bio,
    dto.image,
    isSelf
  )

  let followButtonViewModel = FollowButtonViewModel.new(followButtonDto)

  let viewModel = UserShowViewModel(
    user:user,
    followButtonViewModel:followButtonViewModel,
    loadFavorites:loadFavorites,
    hasPage:hasPage,
    page:page
  )
  return viewModel
