import std/times

type CardViewModel* = object
  body*:string
  createdAt*:string
  userId*:string
  userName*:string
  userImage*:string

proc new*(_:type CardViewModel,
  body:string,
  createdAt:DateTime,
  userId:string,
  userName:string,
  userImage:string
): CardViewModel =
  let createdAt = createdAt.format("yyyy MMMM d")
  return CardViewModel(
    body: body,
    createdAt: createdAt,
    userId: userId,
    userName: userName,
    userImage: userImage
  )
