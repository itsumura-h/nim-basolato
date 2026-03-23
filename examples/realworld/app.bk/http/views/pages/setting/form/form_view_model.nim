type User*  = object
  name*:string
  email*:string
  bio*:string
  image*:string

proc new*(_:type User, name:string, email:string, bio:string, image:string): User =
  return User(
    name: name,
    email: email,
    bio: bio,
    image: image
  )


type FormViewModel*  = object
  oobSwap*:bool
  user*:User

proc new*(_:type FormViewModel, oobSwap:bool, name:string, email:string, bio:string, image:string): FormViewModel =
  let user = User.new(name, email, bio, image)
  return FormViewModel(
    user: user,
    oobSwap: oobSwap
  )
