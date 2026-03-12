import std/times


type TagDto*  = object
  id*:string
  name*:string


type AuthorDto*  = object
  id*:string
  name*:string
  image*:string
  followerCount*:int

proc new*(_:type AuthorDto, id, name, image:string, followerCount:int):AuthorDto =
  return AuthorDto(
    id:id,
    name:name,
    image:image,
    followerCount:followerCount,
  )


type ArticleDetailDto*  = object
  id*:string
  title*:string
  description*:string
  body*:string
  createdAt*:DateTime
  popularCount*:int
  author*:AuthorDto
  tagList*:seq[TagDto]

proc new*(_:type ArticleDetailDto,
  id:string,
  title:string,
  description:string,
  body:string,
  createdAt:string,
  popularCount:int,
  author:AuthorDto,
  tagList:seq[TagDto]
):ArticleDetailDto =
  let createdAt = parse(createdAt, "yyyy-MM-dd hh:mm:ss")
  return ArticleDetailDto(
    id:id,
    title:title,
    description:description,
    body:body,
    createdAt:createdAt,
    popularCount:popularCount,
    author:author,
    tagList:tagList
  )
