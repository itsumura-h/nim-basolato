import tables

import user/repositories/user_rdb_repository
export user_rdb_repository


let dependencies* = {
  "userRepository": newUserRdbRepository(),
}.toTable()


# import user/repositories/user_json_repository
# export user_json_repository

# let dependencies* = {
#   "userRepository": newUserJsonRepository(),
# }.toTable()
