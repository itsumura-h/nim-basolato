import std/asyncdispatch
import interface_implements
import ./article_with_author_dto


interfaceDefs:
  type IGlobalFeedArticleListQuery* = object of RootObj
    invoke*: proc(
        self:IGlobalFeedArticleListQuery,
        offset:int,
        display:int
      ):Future[seq[ArticleWithAuthorDto]]

# type IGlobalFeedArticleListQuery* = object
#   invoke*: proc(
#       offset:int,
#       display:int
#     ):Future[seq[ArticleWithAuthorDto]]
