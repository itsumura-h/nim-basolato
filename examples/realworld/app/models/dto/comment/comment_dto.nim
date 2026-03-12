import std/times

type CommentDto* = object
  authorId*: string
  authorName*: string
  authorImage*: string
  content*: string
  createdAt*: DateTime

proc new*(_:type CommentDto, authorId: string, authorName: string, authorImage: string, content: string, createdAt: DateTime):CommentDto =
  return CommentDto(
    authorId: authorId,
    authorName: authorName,
    authorImage: authorImage,
    content: content,
    createdAt: createdAt,
  )
