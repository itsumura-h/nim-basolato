import ../../value_objects
import ./user_entity

type IUserRepository* = tuple
  storeUser: proc(name:UserName, email:UserEmail, hashedPassword:HashedPassword):UserId
  getUser: proc(email:UserEmail):User
