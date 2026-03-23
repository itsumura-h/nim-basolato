
import std/asyncdispatch
import interface_implements


interfaceDefs:
  type IYourFeedArticleCountDao* = object of RootObj
    invoke*: proc(
        self:IYourFeedArticleCountDao,
        loginUserId:string,
      ): Future[int]
