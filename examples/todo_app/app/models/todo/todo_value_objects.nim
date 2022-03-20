import times, markdown
import ../../../libs/uid

type TodoId* = ref object
  value:string

func new*(_:type TodoId, value:string):TodoId =
  TodoId(
    value: value
  )

proc new*(_:type TodoId):TodoId =
  TodoId(
    value: genUid()
  )

proc `$`*(self:TodoId):string =
  return self.value


type Title* = ref object
  value:string

func new*(_:type Title, value:string):Title =
  Title(
    value: value
  )

proc `$`*(self:Title):string =
  return self.value


type Content* = ref object
  value:string

func new*(_:type Content, value:string):Content =
  Content(
    value: value
  )

proc `$`*(self:Content):string =
  return self.value

proc toHtml*(self:Content):string =
  return markdown(self.value)


type TodoDate* = ref object
  value:DateTime

proc new*(_:type TodoDate, value:string):TodoDate =
  TodoDate(
    value: value.parse("yyyy-MM-dd")
  )

proc `$`*(self:TodoDate):string =
  return self.value.format("yyyy-MM-dd")

proc isLaterThan*(self, other:TodoDate):bool =
  return self.value >= other.value


type Status* = ref object
  ## Todo, Doing or Done
  value:int

func new*(_:type Status, value:int=1):Status =
  Status(
    value: value
  )

proc get*(self:Status):int =
  return self.value


type Sort* = ref object
  value:int

func new*(_:type Sort, value:int):Sort =
  Sort(
    value: value
  )

proc get*(self:Sort):int =
  return self.value
