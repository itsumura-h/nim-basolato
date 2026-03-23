import std/asyncdispatch
import std/options
import basolato/view
import ../../../../di_container
import ../../../../models/dto/user/user_dao_interface


type UserInfoTemplateModel* = object
  id*: string
  name*: string
  image*: string
  bio*: string
  isSameUser*: bool
  isFollowed*: bool
  csrfToken*: CsrfToken


proc new*(_: type UserInfoTemplateModel, id: string, name: string, image: string, bio: string, isSameUser: bool, isFollowed: bool, csrfToken: CsrfToken): UserInfoTemplateModel =
  UserInfoTemplateModel(
    id: id,
    name: name,
    image: image,
    bio: bio,
    isSameUser: isSameUser,
    isFollowed: isFollowed,
    csrfToken: csrfToken,
  )


proc new*(_: type UserInfoTemplateModel, context: Context): Future[UserInfoTemplateModel] {.async.} =
  let isLogin = context.isLogin().await
  let loginUserId =
    if isLogin:
      context.get("user_id").await.some()
    else:
      none(string)
  let userId = context.params.getStr("userId")
  let userDto = di.userDao.getUserById(userId, loginUserId).await
  let csrfToken = context.csrfToken()
  return UserInfoTemplateModel.new(
    userDto.id,
    userDto.name,
    userDto.image,
    userDto.bio,
    loginUserId.isSome() and loginUserId.get() == userId,
    userDto.isFollowed,
    csrfToken,
  )
