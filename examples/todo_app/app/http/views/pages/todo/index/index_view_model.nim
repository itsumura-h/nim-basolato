import json, asyncdispatch, sequtils
import ../../../../../usecases/todo/display_index_usecase
import ../../../layouts/todo/app_bar/app_bar_view_model
import ../../../layouts/todo/statuses/statuses_view_model


type IndexViewModel* = ref object
  appBarViewModel:AppBarViewModel
  isAdmin:bool
  users:seq[JsonNode]
  statuses: StatusesViewModel

proc appBarViewModel*(self:IndexViewModel):AppBarViewModel = self.appBarViewModel
proc users*(self:IndexViewModel):seq[JsonNode] = self.users
proc isAdmin*(self:IndexViewModel):bool = self.isAdmin
proc statuses*(self:IndexViewModel):StatusesViewModel = self.statuses

proc new*(_:type IndexViewModel, loginUser:JsonNode):Future[IndexViewModel] {.async.} =
  let usecase = DisplayIndexUsecase.new()
  let data = usecase.run.await
  let isAdmin = loginUser["auth"].getInt < 3
  let statuses = StatusesViewModel.new(data["statuses"].getElems, data["tasks"].getElems)

  return IndexViewModel(
    appBarViewModel:AppBarViewModel.new(loginUser["name"].getStr),
    users:data["users"].getElems,
    isAdmin:isAdmin,
    statuses:statuses
  )
