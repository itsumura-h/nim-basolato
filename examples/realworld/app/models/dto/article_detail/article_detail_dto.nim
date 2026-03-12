import std/times


type ArticleDetailDto* = object
  id*:string
  title*:string
  content*:string
  createdAt*:DateTime
  updatedAt*:DateTime
  authorId*:string
  favoriteCount*:int

proc new*(_:type ArticleDetailDto,
  id:string,
  title:string,
  content:string,
  createdAt:DateTime,
  updatedAt:DateTime,
  authorId:string,
  favoriteCount:int
): ArticleDetailDto =
  return ArticleDetailDto(
    id: id,
    title: title,
    content: content,
    createdAt: createdAt,
    updatedAt: updatedAt,
    authorId: authorId,
    favoriteCount: favoriteCount,
  )
