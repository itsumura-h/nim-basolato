import asyncdispatch
import ../value_objects
include ../di_container

type IWorldRepository* = ref object

proc newIWorldRepository*():IWorldRepository =
  return IWorldRepository()

proc findWorld*(self:IWorldRepository, i:int) {.async.} =
  await DiContainer.worldRepository().findWorld(i)

proc updateRandomNumber*(self:IWorldRepository, i, number:int) {.async.} =
  await DiContainer.worldRepository().updateRandomNumber(i, number)
