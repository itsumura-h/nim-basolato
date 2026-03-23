import std/asyncdispatch
import interface_implements
import ./paginator_dto

interfaceDefs:
  type ITagFeedArticleListPaginatorQuery* = object of RootObj
    invoke: proc(self:ITagFeedArticleListPaginatorQuery, tagName:string, page:int, display:int): Future[PaginatorDto]
