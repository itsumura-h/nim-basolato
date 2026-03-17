import std/asyncdispatch
import std/options
import basolato/view
import ../../../../di_container
import ../../../../models/dto/user/user_dao_interface


type NavbarLayoutModel*  = object
  isLogin*: bool
  userId*:string
  userName*:string
  image*:string

proc new*(_:type NavbarLayoutModel, context:Context):Future[NavbarLayoutModel] {.async.} =
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_id").await

  if isLogin:
    let userDao:IUserDao = di.userDao
    let userDto = userDao.getUserById(loginUserId).await
    let navbarViewModel = NavbarLayoutModel(
      isLogin:true,
      userId:userDto.id,
      userName:userDto.name,
      image:userDto.image,
    )
    return navbarViewModel
  else:
    let navbarViewModel = NavbarLayoutModel(isLogin:false, userId:"", userName:"", image:"")
    return navbarViewModel
