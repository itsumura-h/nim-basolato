import user_value_objects
import ./user_entity

type IUserRepository* = tuple
  storeUser: proc(a:UserName, b:UserEmail, c:HashedPassword):UserId
  getUser: proc(a:UserEmail):User
