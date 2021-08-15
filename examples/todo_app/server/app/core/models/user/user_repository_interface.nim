import asyncdispatch
import user_value_objects
import ./user_entity

type IUserRepository* = tuple
  storeUser: proc(a:UserName, b:UserEmail, c:HashedPassword):Future[UserId]
  getUser: proc(a:UserEmail):Future[User]
