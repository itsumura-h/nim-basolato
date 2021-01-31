import allographer/query_builder
import ../../model/value_objects
import ../../model/aggregates/circle/circle_repository_interface


type CircleRdbRepository* = ref object

proc newCircleRepository*():CircleRdbRepository =
  return CircleRdbRepository()


proc toInterface*(this:CircleRdbRepository):ICircleRepository =
  return ()
