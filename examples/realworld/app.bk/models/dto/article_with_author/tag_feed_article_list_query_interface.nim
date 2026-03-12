import std/asyncdispatch
import interface_implements
import ./article_with_author_dto


interfaceDefs:
  type ITagFeedArticleListQuery* = object of RootObj
    invoke: proc(
        self:ITagFeedArticleListQuery,
        tagName:string,
        offset:int,
        display:int
      ):Future[seq[ArticleWithAuthorDto]]
