type UserDto* = object
  id*:string
  name*:string
  email*:string
  bio*:string
  image*:string
  followerCount*:int

proc new*(_:type UserDto, id, name, email, bio, image: string, followerCount:int): UserDto =
  return UserDto(
    id:id,
    name: name,
    email: email,
    bio: bio,
    image: image,
    followerCount: followerCount,
  )
  