import tables
import models/user/repositories/user_rdb_repository
import models/user/repositories/user_json_repository

let rdbRepositories = {
    "userRepository": newUserRdbRepository()
}

let jsonRepositories = {
    "userRepository": newUserJsonRepository()
}