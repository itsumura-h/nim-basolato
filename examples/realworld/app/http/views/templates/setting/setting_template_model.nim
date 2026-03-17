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
  csrfToken*: CsrfToken


proc new*(_: type SettingTemplateModel, context: Context): Future[SettingTemplateModel] {.async.} =
  let params = context.getParams().await
  let errors = context.getErrors().await
  let csrfToken = context.csrfToken()
  if errors.len > 0:
    return SettingTemplateModel(
      errors: errors,
      image: params.old("image"),
      name: params.old("name"),
      bio: params.old("bio"),
      email: params.old("email"),
      csrfToken: csrfToken
    )
  else:
    let userId = context.get("user_id").await
    let dto = di.userDao.getUserById(userId).await
    return SettingTemplateModel(
      image: dto.image,
      name: dto.name,
      bio: dto.bio,
      email: dto.email,
      csrfToken: csrfToken
    )
