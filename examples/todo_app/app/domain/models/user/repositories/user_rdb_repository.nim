import allographer/query_builder
import ../user_entity
import ../../value_objects


type UserRdbRepository* = ref object


proc newUserRepository*():UserRdbRepository =
  return UserRdbRepository()

proc sampleProc*(this:UserRdbRepository) =
  echo "UserRdbRepository sampleProc"
