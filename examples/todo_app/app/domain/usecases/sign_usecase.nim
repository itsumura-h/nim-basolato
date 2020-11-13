import ../models/value_objects
import ../models/user/user_repository_interface


type SignUsecase* = ref object
  repository:IUserRepository

proc newSignUsecase*():SignUsecase =
  return SignUsecase(
    repository: IUserRepository()
  )

proc signIn*(this:SignUsecase, name, email, password:string) =
  let name = newUserName(name)
  let email = newUserEmail(email)
  let password = newPassword(password).getHashed()
  this.repository.storeUser(name, email, password)
