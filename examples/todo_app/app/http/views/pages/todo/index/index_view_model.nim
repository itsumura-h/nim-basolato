import json, asyncdispatch, sequtils
import ../../../../../usecases/todo/display_index_usecase
import ../../../layouts/todo/app_bar/app_bar_view_model
import ../../../layouts/todo/status/status_view_model


type IndexViewModel* = ref object
  appBarViewModel:AppBarViewModel
  isAdmin:bool
  users:seq[JsonNode]
  statuses: seq[StatusViewModel]
  todo:seq[JsonNode]
  doing:seq[JsonNode]
  done:seq[JsonNode]

proc appBarViewModel*(self:IndexViewModel):AppBarViewModel = self.appBarViewModel
proc users*(self:IndexViewModel):seq[JsonNode] = self.users
proc isAdmin*(self:IndexViewModel):bool = self.isAdmin
proc statuses*(self:IndexViewModel):seq[StatusViewModel] = self.statuses
proc todo*(self:IndexViewModel):seq[JsonNode] = self.todo
proc doing*(self:IndexViewModel):seq[JsonNode] = self.doing
proc done*(self:IndexViewModel):seq[JsonNode] = self.done

proc new*(_:type IndexViewModel, loginUser:JsonNode):Future[IndexViewModel] {.async.} =
  let usecase = DisplayIndexUsecase.new()
  let data = usecase.run.await
  let isAdmin = loginUser["auth"].getInt < 3
  let statuses = data["statuses"].getElems.map(
    proc(row:JsonNode):StatusViewModel =
      return StatusViewModel.new(
        row["id"].getInt,
        row["name"].getStr
      )
  )

  var todo, doing, done:seq[JsonNode] = @[]
  for row in data["tasks"]:
    if row["status"].getStr == "todo":
      todo.add(row)
    elif row["status"].getStr == "doing":
      doing.add(row)
    elif row["status"].getStr == "done":
      done.add(row)
  
  return IndexViewModel(
    appBarViewModel:AppBarViewModel.new(loginUser["name"].getStr),
    users:data["users"].getElems,
    isAdmin:isAdmin,
    statuses:statuses,
    todo:todo,
    doing:doing,
    done:done,
  )
