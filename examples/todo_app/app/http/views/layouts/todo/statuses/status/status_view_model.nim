import json, sequtils
import ./task/task_view_model

type StatusViewModel* = ref object
  id:int
  name:string
  hasLeftItem:bool
  hasRightItem:bool
  tasks:seq[TaskViewModel]

proc id*(self:StatusViewModel):int = self.id
proc name*(self:StatusViewModel):string = self.name
proc hasLeftItem*(self:StatusViewModel):bool = self.hasLeftItem
proc hasRightItem*(self:StatusViewModel):bool = self.hasRightItem
proc tasks*(self:StatusViewModel):seq[TaskViewModel] = self.tasks

proc new*(
  _:type StatusViewModel,
  id:int,
  name:string,
  tasks:seq[JsonNode],
  hasLeftItem, hasRightItem:bool
):StatusViewModel =
  var newTasks: seq[TaskViewModel]
  for i, task in tasks:
    let isDisplayUp = (i != 0)
    let upId =
      if isDisplayUp:
        tasks[i-1]["id"].getStr
      else:
        ""
    let isDisplayDown = (i != (tasks.len - 1))
    let downId =
      if isDisplayDown:
        tasks[i+1]["id"].getStr
      else:
        ""
    newTasks.add(
      TaskViewModel.new(task, isDisplayUp, isDisplayDown, upId, downId)
    )
  return StatusViewModel(
    id:id,
    name:name,
    tasks:newTasks,
    hasLeftItem:hasLeftItem,
    hasRightItem:hasRightItem
  )
