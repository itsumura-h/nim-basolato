import ../value_objects
include ../di_container


type IUserRepository* = ref object


proc newIUserRepository*():IUserRepository =
  return newIUserRepository()

proc storeUser*(this:IUserRepository,
  name:UserName,
  email:UserEmail,
  password:HashedPassword
) =
  DiContainer.userRepository().storeUser(name, email, password)
