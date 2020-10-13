import asyncdispatch, json
import allographer/query_builder
import ../world_entity
import ../../value_objects

type WorldRdbRepository* = ref object

proc newWorldRepository*():WorldRdbRepository =
  return WorldRdbRepository()

proc sampleProc*(this:WorldRdbRepository) =
  echo "WorldRdbRepository sampleProc"

proc findWorld*(this:WorldRdbRepository, i:int) {.async.} =
  discard await rdb().table("world").asyncFind(i)

proc updateRandomNumber*(this:WorldRdbRepository, i, number:int) {.async.} =
  await rdb().table("world").where("id", "=", i).asyncUpdate(%*{"randomNumber": number})
