
import std/asyncdispatch
import interface_implements


interfaceDefs:
  type ITagFeedArticleCountDao* = object of RootObj
    invoke*: proc(
        self:ITagFeedArticleCountDao,
        tagId:string,
      ): Future[int]
