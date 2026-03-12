import basolato/view
import ../../di_container
import ../../models/dto/user/user_dao_interface
import ../../models/vo/user_id
import ../../http/views/templates/setting/setting_template_model


type SettingPresenter* = object
  userDao:IUserDao

proc new*(_:type SettingPresenter):SettingPresenter =
  return SettingPresenter(
    userDao: di.userDao
  )


proc invoke*(self:SettingPresenter):Future[SettingTemplateModel] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await

  if errors.len > 0:
    let model = SettingTemplateModel.new(
      errors,
      params.old("image"),
      params.old("name"),
      params.old("bio"),
      params.old("email")
    )
    return model
  else:
    let userId = context.get("user_id").await

    let dto = self.userDao.getUserById(userId).await
    let model = SettingTemplateModel.new(
      dto.image,
      dto.name,
      dto.bio,
      dto.email,
    )
    return model
