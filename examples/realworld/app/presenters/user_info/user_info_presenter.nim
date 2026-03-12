import std/asyncdispatch
import basolato/view
import ../../di_container
import ../../models/dto/user/user_dto
import ../../models/dto/user/user_dao_interface
import ../../http/views/templates/user_info/user_info_template_model

type UserInfoPresenter* = object
  userDao*: IUserDao

proc new*(_:type UserInfoPresenter): UserInfoPresenter =
  return UserInfoPresenter(
    userDao: di.userDao
  )


proc invoke*(self: UserInfoPresenter): Future[UserInfoTemplateModel] {.async.} =
  let context = context()
  let loginUserId = context.get("user_id").await
  let userId = context.params.getStr("userId")
  let userDto = self.userDao.getUserById(userId).await

  let model = UserInfoTemplateModel.new(
    id = userDto.id,
    name = userDto.name,
    image = userDto.image,
    bio = userDto.bio,
    isSameUser = loginUserId == userId
  )
  return model
