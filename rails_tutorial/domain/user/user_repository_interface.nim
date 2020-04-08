import repositories/user_rdb_repository
export user_rdb_repository

# import repositories/user_json_repository
# export user_json_repository

type IUserRepository* = ref object of RootObj
  repository*:UserRepository

proc newIUserRepository*():UserRepository =
  return newUserRepository()
