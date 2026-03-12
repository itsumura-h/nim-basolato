
import std/asyncdispatch
import interface_implements
import ./tag_dto

interfaceDefs:
  type ITagDao* = object of RootObj
    getPopularTagList*: proc(self: ITagDao): Future[seq[TagDto]]
