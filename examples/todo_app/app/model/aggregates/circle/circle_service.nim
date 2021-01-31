import ../../value_objects
import circle_entity
import circle_repository_interface


type CircleService* = ref object
  repository: ICircleRepository

proc newCircleService*(repository:ICircleRepository):CircleService =
  return CircleService(
    repository: repository
  )
