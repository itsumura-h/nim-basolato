import std/asyncdispatch
import std/options
import interface_implements
import ./comment_entity

interfaceDefs:
  type ICommentRepository* = object of RootObj
    getCommentById: proc(self: ICommentRepository, commentId: int): Future[Option[Comment]]
    create: proc(self: ICommentRepository, comment: Comment): Future[void]
    delete: proc(self: ICommentRepository, commentId: int): Future[void]
