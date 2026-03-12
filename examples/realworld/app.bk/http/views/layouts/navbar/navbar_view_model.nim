type NavbarViewModel*  = object
  isLogin*: bool
  userId*:string
  userName*:string
  image*:string

proc new*(_:type NavbarViewModel, isLogin: bool, id:string, name:string, image:string): NavbarViewModel =
  return NavbarViewModel(
    isLogin: isLogin,
    userId:id,
    userName:name,
    image:image
  )
