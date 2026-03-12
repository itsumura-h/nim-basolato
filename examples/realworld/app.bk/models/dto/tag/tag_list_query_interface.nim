import std/asyncdispatch
import interface_implements
import ./tag_dto

interfaceDefs:
  type ITagListQuery* = object of RootObj
    invoke: proc(self:ITagListQuery, count:int):Future[seq[TagDto]]
