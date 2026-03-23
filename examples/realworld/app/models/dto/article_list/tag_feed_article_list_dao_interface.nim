
import std/asyncdispatch
import interface_implements
import ./article_list_dto


interfaceDefs:
  type ITagFeedArticleListDao* = object of RootObj
    invoke*: proc(
        self:ITagFeedArticleListDao,
        tagId:string,
        offset:int,
        display:int,
      ):Future[seq[ArticleDto]]
