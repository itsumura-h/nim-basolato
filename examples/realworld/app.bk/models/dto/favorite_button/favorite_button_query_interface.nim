import std/asyncdispatch
import interface_implements
import ../../vo/article_id
import ../../vo/user_id
import ./favorite_button_dto


interfaceDefs:
  type IFavoriteButtonQuery* = object of RootObj
    invoke*:proc(self:IFavoriteButtonQuery, articleId:ArticleId, userId:UserId):Future[FavoriteButtonDto]
    invoke*:proc(self:IFavoriteButtonQuery, articleId:ArticleId):Future[FavoriteButtonDto]
