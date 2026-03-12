import std/asyncdispatch
import std/options
import interface_implements
import ./user_entity
import ../../vo/email
import ../../vo/user_id


interfaceDefs:
  type IUserRepository*  = object of RootObj
    getUserByEmail:proc(self:IUserRepository, email:Email):Future[Option[User]]
    getUserById:proc(self:IUserRepository, userId:UserId):Future[Option[User]]
    create:proc(self:IUserRepository, user:DraftUser):Future[UserId]
    update:proc(self:IUserRepository, user:User):Future[void]
