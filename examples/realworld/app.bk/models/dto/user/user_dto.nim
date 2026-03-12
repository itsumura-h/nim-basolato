type UserDto* = object
  id*:string
  name*:string
  email*:string
  bio*:string
  image*:string

proc new*(_:type UserDto, id, name, email, bio, image: string): UserDto =
  return UserDto(
    id:id,
    name: name,
    email: email,
    bio: bio,
    image: image,
  )
  