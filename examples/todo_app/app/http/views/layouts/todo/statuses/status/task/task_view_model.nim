import json

type TaskViewModel* = ref object
  id:string
  title:string
  createdId:string
  createdName:string
  assignId:string
  assignName:string
  startOn:string
  endOn:string
  statusId:int
  sort:int
  isDisplayUp:bool
  isDisplayDown:bool
  upId:string
  downId:string

proc id*(self:TaskViewModel):string = self.id
proc title*(self:TaskViewModel):string = self.title
proc createdId*(self:TaskViewModel):string = self.createdId
proc createdName*(self:TaskViewModel):string = self.createdName
proc assignId*(self:TaskViewModel):string = self.assignId
proc assignName*(self:TaskViewModel):string = self.assignName
proc startOn*(self:TaskViewModel):string = self.startOn
proc endOn*(self:TaskViewModel):string = self.endOn
proc statusId*(self:TaskViewModel):int = self.statusId
proc sort*(self:TaskViewModel):int = self.sort
proc isDisplayUp*(self:TaskViewModel):bool = self.isDisplayUp
proc isDisplayDown*(self:TaskViewModel):bool = self.isDisplayDown
proc upId*(self:TaskViewModel):string = self.upId
proc downId*(self:TaskViewModel):string = self.downId

proc new*(_: type TaskViewModel,
  task:JsonNode,
  isDisplayUp, isDisplayDown:bool,
  upId, downId:string
):TaskViewModel =
  return TaskViewModel(
    id: task["id"].getStr,
    title: task["title"].getStr,
    createdId: task["created_id"].getStr,
    createdName: task["created_name"].getStr,
    assignId: task["assign_id"].getStr,
    assignName: task["assign_name"].getStr,
    startOn: task["start_on"].getStr,
    endOn: task["end_on"].getStr,
    statusId: task["status_id"].getInt,
    sort: task["sort"].getInt,
    isDisplayUp:isDisplayUp,
    isDisplayDown:isDisplayDown,
    upId:upId,
    downId:downId
  )
