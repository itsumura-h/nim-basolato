type UserInfoTemplateModel* = object
  id*: string
  name*:string
  image*:string
  bio*:string
  isSameUser*:bool

proc new*(_:type UserInfoTemplateModel, id:string, name:string, image:string, bio:string, isSameUser:bool):UserInfoTemplateModel =
  return UserInfoTemplateModel(
    id: id,
    name: name,
    image: image,
    bio: bio,
    isSameUser: isSameUser
  )
