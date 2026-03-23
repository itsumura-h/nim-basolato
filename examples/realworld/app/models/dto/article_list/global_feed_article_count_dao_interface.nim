
import std/asyncdispatch
import interface_implements


interfaceDefs:
  type IGlobalFeedArticleCountDao* = object of RootObj
    invoke*: proc(
        self:IGlobalFeedArticleCountDao,
      ): Future[int]
