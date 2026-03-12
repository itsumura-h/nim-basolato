import std/asyncdispatch
import ../../../models/dto/comment/comment_list_query_interface
import ../../../models/dto/comment/comment_dto
import ../../../models/vo/article_id


type MockCommentListQuery* = object of ICommentListQuery

proc new*(_:type MockCommentListQuery):MockCommentListQuery =
  return MockCommentListQuery()


method invoke*(self:MockCommentListQuery, articleId:ArticleId):Future[seq[CommentDto]] {.async.} =
  discard
