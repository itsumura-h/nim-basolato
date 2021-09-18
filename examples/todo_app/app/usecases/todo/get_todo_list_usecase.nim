import ../../di_container


type GetTodoListUsecase* = ref object

proc new*(typ:type GetTodoListUsecase):GetTodoListUsecase =
  typ()

proc run*(self:GetTodoListUsecase) =
  discard
