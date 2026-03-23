import std/asyncdispatch
import interface_implements
import ./comment_dto

interfaceDefs:
  type ICommentDao* = object of RootObj
    getCommentListByArticleId: proc(self: ICommentDao, articleId: string): Future[seq[CommentDto]]
