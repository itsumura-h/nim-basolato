import std/asyncdispatch
import interface_implements
import ./article_with_author_dto
import ../../vo/user_id


interfaceDefs:
  type IUserArticleListQuery* = object of RootObj
    invoke: proc(
        self:IUserArticleListQuery,
        userId:UserId,
        offset:int,
        display:int
      ):Future[seq[ArticleWithAuthorDto]]
