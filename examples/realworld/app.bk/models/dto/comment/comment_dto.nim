import std/times

type UserDto*  = object
  id*:string
  name*:string
  image*:string

proc new*(_:type UserDto, id, name, image:string):UserDto =
  return UserDto(
    id:id,
    name:name,
    image:image
  )


type CommentDto*  = object
  user*:UserDto
  body*:string
  createdAt*:DateTime

proc new*(_:type CommentDto, user:UserDto, body:string, createdAt:DateTime):CommentDto =
  return CommentDto(
    user:user,
    body:body,
    createdAt:createdAt
  )
