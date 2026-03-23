import ../../vo/user_id
import ../../vo/user_name
import ../../vo/email
import ../../vo/password
import ../../vo/hashed_password
import ../../vo/bio
import ../../vo/image


type DraftUser*  = object
  id*:UserId
  name*:UserName
  email*:Email
  password*:Password


proc new*(_:type DraftUser, userName:UserName, email:Email, password:Password):DraftUser =
  let userId = UserId.new(userName)
  return DraftUser(
    id:userId,
    name:userName,
    email:email,
    password:password,
  )


type User*  = object
  id*:UserId
  name*:UserName
  email*:Email
  password*:HashedPassword
  bio*:Bio
  image*:Image


proc new*(_:type User,
  userId:UserId,
  userName:UserName,
  email:Email,
  password:HashedPassword,
  bio:Bio,
  image:Image,
):User =
  return User(
    id:userId,
    name:userName,
    email:email,
    password:password,
    bio:bio,
    image:image,
  )
