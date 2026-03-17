import std/asyncdispatch
import basolato/view
import ../../../../di_container
import ../../../../models/dto/user/user_dao_interface


type SettingTemplateModel* = object
  errors*: seq[string]
  image*: string
  name*: string
  bio*: string
  email*: string
  csrfToken*: string


proc new*(_: type SettingTemplateModel, errors: seq[string], image: string, name: string, bio: string, email: string, csrfToken: string): SettingTemplateModel =
  SettingTemplateModel(errors: errors, image: image, name: name, bio: bio, email: email, csrfToken: csrfToken)


proc new*(_: type SettingTemplateModel, image: string, name: string, bio: string, email: string, csrfToken: string): SettingTemplateModel =
  SettingTemplateModel(errors: @[], image: image, name: name, bio: bio, email: email, csrfToken: csrfToken)


proc new*(_: type SettingTemplateModel, context: Context): Future[SettingTemplateModel] {.async.} =
  let (params, errors) = context.getParamsWithErrorsList().await
  let csrfToken = context.csrfToken().toString()
  if errors.len > 0:
    return SettingTemplateModel.new(
      errors,
      params.old("image"),
      params.old("name"),
      params.old("bio"),
      params.old("email"),
      csrfToken
    )
  else:
    let userId = context.get("user_id").await
    let dto = di.userDao.getUserById(userId).await
    return SettingTemplateModel.new(dto.image, dto.name, dto.bio, dto.email, csrfToken)
