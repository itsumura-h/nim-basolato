import std/asyncdispatch
import interface_implements
import ../../vo/user_id
import ./paginator_dto


interfaceDefs:
  type IUserArticleListPaginatorQuery* = object of RootObj
    invoke: proc(self:IUserArticleListPaginatorQuery, userId:UserId, page:int, display:int): Future[PaginatorDto]
