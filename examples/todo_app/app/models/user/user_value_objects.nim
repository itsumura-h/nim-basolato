type UserId* = ref object
  value:string

func new*(typ:type UserId, value:string):UserId =
  typ(
    value: value
  )

proc `$`*(self:UserId):string =
  return self.value


type UserName* = ref object
  value:string

func new*(typ:type UserName, value:string):UserName =
  typ(
    value: value
  )

proc `$`*(self:UserName):string =
  return self.value


type Email* = ref object
  value:string

func new*(typ:type Email, value:string):Email =
  typ(
    value: value
  )

proc `$`*(self:Email):string =
  return self.value


type Password* = ref object
  value:string

func new*(typ:type Password, value:string):Password =
  typ(
    value: value
  )

proc `$`*(self:Password):string =
  return self.value


type HashedPassword* = ref object
  value:string

func new*(typ:type HashedPassword, value:string):HashedPassword =
  typ(
    value: value
  )

proc `$`*(self:HashedPassword):string =
  return self.value


type Auth* = ref object
  value:int

func new*(_:type Auth, value:int):Auth =
  Auth(
    value: value
  )

proc get*(self:Auth):int =
  return self.value
