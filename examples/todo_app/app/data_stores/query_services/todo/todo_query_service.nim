import interface_implements
import allographer/query_builder
from ../../../../database import rdb
import ../../../usecases/todo/todo_query_service_interface


type TodoQueryService* = ref object

func new*(typ:type TodoQueryService):TodoQueryService =
  typ()

implements TodoQueryService, ITodoQueryService:
  discard
