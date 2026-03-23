import std/asyncdispatch
import interface_implements
import ../../vo/user_id
import ./paginator_dto


interfaceDefs:
  type IYourFeedArticleListPaginatorQuery* = object of RootObj
    invoke: proc(self:IYourFeedArticleListPaginatorQuery, loginUserId:UserId, page:int, display:int): Future[PaginatorDto]
