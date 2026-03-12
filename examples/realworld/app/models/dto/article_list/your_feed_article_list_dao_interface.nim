
import std/asyncdispatch
import interface_implements
import ./article_list_dto


interfaceDefs:
  type IYourFeedArticleListDao* = object of RootObj
    invoke*: proc(
        self:IYourFeedArticleListDao,
        loginUserId:string,
        offset:int,
        display:int,
      ):Future[seq[ArticleDto]]
