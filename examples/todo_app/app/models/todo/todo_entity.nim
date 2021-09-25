import ../user/user_entity
import todo_value_objects
import ../user/user_value_objects
import ../../../libs/uid


type Todo* = ref object
  id:TodoId
  title:Title
  content:Content
  createdBy:UserId
  assignTo:UserId
  startOn:TodoDate
  endOn:TodoDate
  status:Status
  sort:Sort

proc id*(self:Todo):TodoId = self.id
proc title*(self:Todo):Title = self.title
proc content*(self:Todo):Content = self.content
proc createdBy*(self:Todo):UserId = self.createdBy
proc assignTo*(self:Todo):UserId = self.assignTo
proc startOn*(self:Todo):TodoDate = self.startOn
proc endOn*(self:Todo):TodoDate = self.endOn
proc status*(self:Todo):Status = self.status
proc sort*(self:Todo):Sort = self.sort

proc new*(_:type Todo, title:Title, content:Content, createdBy:UserId,
          assignTo:UserId, startOn:TodoDate, endOn:TodoDate, sort:Sort):Todo =
  ## Used to initialize input data
  ## 
  if not endOn.isLaterThan(startOn):
    raise newException(Exception, "Due date must after than start date")

  let id = TodoId.new(genUid())
  let status = Status.new() # Todo
  return Todo(
    id: id,
    title: title,
    content: content,
    createdBy: createdBy,
    assignTo: assignTo,
    startOn: startOn,
    endOn: endOn,
    status: status,
    sort: sort
  )

proc new*(_:type Todo, id:TodoId, title:Title, content:Content, createdBy:UserId,
          assignTo:UserId, startOn:TodoDate, endOn:TodoDate, status:Status,
          sort:Sort):Todo =
  ## Used to initialize to database fetched data
  if not endOn.isLaterThan(startOn):
    raise newException(Exception, "Due date must after than start date")

  return Todo(
    id: id,
    title: title,
    content: content,
    createdBy: createdBy,
    assignTo: assignTo,
    startOn: startOn,
    endOn: endOn,
    status: status,
    sort: sort
  )
