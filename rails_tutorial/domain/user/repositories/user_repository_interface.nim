import user_rdb_repository
export user_rdb_repository

# import user_json_repository
# export user_json_repository

type IUserRepository* = ref object of RootObj
  repository*:UserRepository

proc newIUserRepository*():IUserRepository =
  return IUserRepository(
    repository:newUserRepository()
  )
