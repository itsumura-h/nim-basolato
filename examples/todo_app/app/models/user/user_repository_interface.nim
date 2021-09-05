import asyncdispatch
import user_value_objects
import user_entity


type IUserRepository* = tuple
  getUserByEmail: proc(email:Email):Future[User]
