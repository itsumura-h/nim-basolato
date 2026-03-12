import std/times
import ../../vo/user_id
import ../../vo/user_name
import ../../vo/email
import ../../vo/password
import ../../vo/hashed_password
import ../../vo/bio
import ../../vo/image


type DraftUser*  = ref object
  id*:UserId  
  name*:UserName
  email*:Email
  password*:HashedPassword
  createdAt*:DateTime


proc new*(_:type DraftUser, userName:UserName, email:Email, password:Password):DraftUser =
  let userId = UserId.new()
  let hashedPassword = HashedPassword.new(password)
  return DraftUser(
    id:userId,
    name:userName,
    email:email,
    password:hashedPassword,
    createdAt:now(),
  )


type User*  = ref object
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
