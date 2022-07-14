import ../../di_container
import todo_query_interface


type DisplayShowUsecase* = ref object
  query: ITodoQuery

proc new*(_:type DisplayShowUsecase):DisplayShowUsecase =
  return DisplayShowUsecase(
    query: di.todoQuery
  )

proc run*(self:DisplayShowUsecase) =
  discard
