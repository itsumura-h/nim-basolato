discard """
  cmd: "APP_ENV=test nim c -r --threads:off -d:reset $file"
"""

# APP_ENV=test nim c -r --threads:off -d:reset tests/test_create_user.nim

import std/unittest
import std/asyncdispatch
import std/json
import allographer/query_builder
import ../app/errors
import ../app/usecases/user/create_user_usecase
import ../database/migrations/test/migrate
from ../config/database import testRdb

let rdb = testRdb

suite("create user"):
  migrate.main()

  test("create user"):
    echo rdb.table("user").get().waitFor()

    let name = "test1"
    let email = "test1@example.com"
    let password = "test1Password"

    let usecase = CreateUserUsecase.new()
    usecase.invoke(name, email, password).waitFor()

  test("deprecate"):
    let name = "test1"
    let email = "test1@example.com"
    let password = "test1Password"

    let usecase = CreateUserUsecase.new()
    
    expect(DomainError):
      usecase.invoke(name, email, password).waitFor()
