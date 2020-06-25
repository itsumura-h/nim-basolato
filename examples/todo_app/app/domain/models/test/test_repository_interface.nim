import options

import repositories/test_rdb_repository
# import repositories/test_json_repository

type ITestRepository* = ref object of RootObj
  repository*:TestRepository

proc newITestRepository*():TestRepository =
  return newTestRepository()
