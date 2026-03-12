
import std/asyncdispatch
import interface_implements


interfaceDefs:
  type IUserArticleCountDao* = object of RootObj
    invoke*: proc(
        self:IUserArticleCountDao,
        userId:string,
      ): Future[int]
