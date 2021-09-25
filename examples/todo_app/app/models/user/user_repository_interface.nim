import asyncdispatch, options
import user_value_objects
import user_entity


type IUserRepository* = tuple
  getUserByEmail: proc(email:Email):Future[Option[User]]
  getUserById: proc(id:UserId):Future[Option[User]]
  save: proc(user:DraftUser):Future[int]
