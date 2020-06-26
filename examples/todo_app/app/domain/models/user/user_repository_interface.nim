import options
import ../value_objects

import repositories/user_rdb_repository
# import repositories/user_json_repository

import user_entity

type IUserRepository* = ref object
  repository*:UserRepository

proc newIUserRepository*():IUserRepository =
  return IUserRepository(
    repository:newUserRepository()
  )

proc find*(this:IUserRepository, email:Email):Option[User] =
  return this.repository.find(email)

proc save*(this:IUserRepository, user:User):int =
  return this.repository.save(user)
