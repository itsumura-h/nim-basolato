from json import JsonNode

# repository
include ../../repositories/ManageUsersRepository

type ManageUsersService* = ref object of RootObj

proc index*(this: ManageUsersService): JsonNode =
  let users = ManageUsersRepository().index()
  return users


proc show*(this: ManageUsersService, id: int): JsonNode =
  let user = ManageUsersRepository().show(id)
  return user
