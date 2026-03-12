
import std/asyncdispatch
import interface_implements
import ./article_list_dto


interfaceDefs:
  type IUserArticleListDao* = object of RootObj
    invoke*: proc(
        self:IUserArticleListDao,
        userId:string,
        offset:int,
        display:int,
      ):Future[seq[ArticleDto]]
