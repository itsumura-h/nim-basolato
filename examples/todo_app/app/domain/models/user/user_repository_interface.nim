import options

# import repositories/user_rdb_repository
import repositories/user_json_repository

import user_entity

type IUserRepository* = ref object of RootObj
  repository*:UserRepository

proc newIUserRepository*():IUserRepository =
  return IUserRepository(
    repository:newUserRepository()
  )

proc print*(this:IUserRepository) =
  this.repository.print()

proc find*(this:IUserRepository, email:string):Option[User] =
  return this.repository.find(email)
