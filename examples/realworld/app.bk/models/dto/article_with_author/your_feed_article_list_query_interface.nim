import std/asyncdispatch
import interface_implements
import ./article_with_author_dto
import ../../vo/user_id


interfaceDefs:
  type IYourFeedArticleListQuery* = object of RootObj
    invoke: proc(
        self:IYourFeedArticleListQuery,
        userId:UserId,
        offset:int,
        display:int
      ):Future[seq[ArticleWithAuthorDto]]
