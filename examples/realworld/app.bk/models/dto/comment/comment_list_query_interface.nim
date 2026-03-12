import std/asyncdispatch
import interface_implements
import ../../vo/article_id
import ./comment_dto

interfaceDefs:
  type ICommentListQuery* = object of RootObj
    invoke:proc(self:ICommentListQuery, articleId:ArticleId):Future[seq[CommentDto]]
