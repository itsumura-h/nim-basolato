import std/asyncdispatch
import ../models/aggregates/user/user_entity
import ../models/aggregates/user/user_repository_interface
import ../models/vo/user_id
import ../models/vo/user_name
import ../models/vo/email
import ../models/vo/password
import ../models/vo/bio
import ../models/vo/image
import ../models/vo/hashed_password
import ../di_container


type UpdateSettingUsecase* = object
  repository:IUserRepository

proc new*(_:type UpdateSettingUsecase):UpdateSettingUsecase =
  return UpdateSettingUsecase(
    repository: di.userRepository
  )


proc invoke*(
  self:UpdateSettingUsecase,
  userId:string,
  name:string,
  email:string,
  password:string,
  bio:string,
  image:string
) {.async.} = 
  let userId = UserId.new(userId)
  let image = Image.new(image)
  let name = UserName.new(name)
  let bio = Bio.new(bio)
  let email = Email.new(email)
  let password = Password.new(password)
  let hashedPassword = HashedPassword.new(password)
  let user = User.new(userId, name, email, hashedPassword, bio, image)
  self.repository.update(user).await
