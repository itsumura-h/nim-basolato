import ../value_objects
import fortune_entity
import fortune_repository_interface
type FortuneService* = ref object
  repository:IFortuneRepository
proc newFortuneService*():FortuneService =
  return FortuneService(
    repository:newIFortuneRepository()
  )
