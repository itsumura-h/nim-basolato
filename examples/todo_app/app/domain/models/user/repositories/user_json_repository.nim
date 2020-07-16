import options

import ../user_entity
import ../../value_objects

type UserJsonRepository = ref object

proc newUserJsonRepository*():UserJsonRepository =
  return UserJsonRepository()


proc find*(this:UserJsonRepository, email:string):Option[User] =
  return some(
    User(
      email: newEmail(email)
    )
  )

proc save*(this:UserJsonRepository, user:User):int =
  return 0
