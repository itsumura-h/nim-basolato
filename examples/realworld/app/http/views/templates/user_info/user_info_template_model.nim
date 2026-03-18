import std/asyncdispatch
import basolato/view
import ../../../../di_container
import ../../../../models/dto/user/user_dao_interface


type UserInfoTemplateModel* = object
  id*: string
  name*: string
  image*: string
  bio*: string
  isSameUser*: bool
  csrfToken*: CsrfToken


proc new*(_: type UserInfoTemplateModel, id: string, name: string, image: string, bio: string, isSameUser: bool, csrfToken: CsrfToken): UserInfoTemplateModel =
  UserInfoTemplateModel(
    id: id,
    name: name,
    image: image,
    bio: bio,
    isSameUser: isSameUser,
    csrfToken: csrfToken,
  )


proc new*(_: type UserInfoTemplateModel, context: Context): Future[UserInfoTemplateModel] {.async.} =
  let loginUserId = context.get("user_id").await
  let userId = context.params.getStr("userId")
  let userDto = di.userDao.getUserById(userId).await
  let csrfToken = context.csrfToken()
  return UserInfoTemplateModel.new(
    userDto.id,
    userDto.name,
    userDto.image,
    userDto.bio,
    loginUserId == userId,
    csrfToken,
  )
