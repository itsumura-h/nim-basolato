import std/asyncdispatch
import std/options
import interface_implements
import ./follow_button_dto
import ../../vo/user_id


interfaceDefs:
  type IFollowButtonQuery* = object of Rootobj
    invoke: proc(self:IFollowButtonQuery, userId:UserId, loginUserId:Option[UserId]):Future[FollowButtonDto]
