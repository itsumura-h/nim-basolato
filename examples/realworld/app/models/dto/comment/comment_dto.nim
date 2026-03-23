import std/times

type CommentDto* = object
  id*: int
  authorId*: string
  authorName*: string
  authorImage*: string
  content*: string
  createdAt*: DateTime

proc new*(_:type CommentDto, id: int, authorId: string, authorName: string, authorImage: string, content: string, createdAt: DateTime):CommentDto =
  return CommentDto(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorImage: authorImage,
    content: content,
    createdAt: createdAt,
  )
