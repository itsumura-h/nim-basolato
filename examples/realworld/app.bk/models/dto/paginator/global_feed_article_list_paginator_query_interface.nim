import std/asyncdispatch
import interface_implements
import ./paginator_dto

interfaceDefs:
  type IGlobalFeedArticleListPaginatorQuery* = object of RootObj
    invoke: proc(self:IGlobalFeedArticleListPaginatorQuery, page:int, display:int): Future[PaginatorDto]
