import std/asyncdispatch
import interface_implements
import ./favorite_entity


interfaceDefs:
  type IFavoriteRepository* = object of RootObj
    isExists:proc(self:IFavoriteRepository, favorite:Favorite):Future[bool]
    create:proc(self:IFavoriteRepository, favorite:Favorite):Future[void]
    delete:proc(self:IFavoriteRepository, favorite:Favorite):Future[void]
