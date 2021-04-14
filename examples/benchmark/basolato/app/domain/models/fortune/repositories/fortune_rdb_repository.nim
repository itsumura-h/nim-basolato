import allographer/query_builder
import ../fortune_entity
import ../../value_objects
type FortuneRdbRepository* = ref object
proc newFortuneRepository*():FortuneRdbRepository =
  return FortuneRdbRepository()
proc sampleProc*(self:FortuneRdbRepository) =
  echo "FortuneRdbRepository sampleProc"
