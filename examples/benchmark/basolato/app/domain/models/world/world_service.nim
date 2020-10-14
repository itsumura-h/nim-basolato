import ../value_objects
import world_entity
import world_repository_interface
type WorldService* = ref object
  repository:IWorldRepository
proc newWorldService*():WorldService =
  return WorldService(
    repository:newIWorldRepository()
  )
