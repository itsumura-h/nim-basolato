import options

import user_repository

import ../user_entity
import ../../value_objects


proc newUserJsonRepository*():UserRepository =
  return UserRepository()


proc find*(this:UserRepository, email:string):Option[User] =
  return some(
    User(
      email: newEmail(email)
    )
  )

proc save*(this:UserRepository, user:User):int =
  return 0
