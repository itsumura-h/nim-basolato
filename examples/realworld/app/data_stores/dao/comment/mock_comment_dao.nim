import std/asyncdispatch
import std/times
import ../../../models/dto/comment/comment_dto
import ../../../models/dto/comment/comment_dao_interface

type MockCommentDao* = object of ICommentDao

proc new*(_:type MockCommentDao): MockCommentDao =
  return MockCommentDao()


method getCommentListByArticleId*(self: MockCommentDao, articleId: string): Future[seq[CommentDto]] {.async.} =
  let commentList = @[
    CommentDto.new(
      authorId = "1",
      authorName = "authorName1",
      authorImage = "http://i.imgur.com/Qr71crq.jpg",
      content = "content1",
      createdAt = "2021-01-01".parse("yyyy-MM-dd"),
    ),
    CommentDto.new(
      authorId = "2",
      authorName = "authorName2",
      authorImage = "http://i.imgur.com/Qr71crq.jpg",
      content = "content2",
      createdAt = "2021-01-01".parse("yyyy-MM-dd"),
    ),
  ]
  return commentList
