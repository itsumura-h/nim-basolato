from json import JsonNode

# repository
import ../../repositories/ManageUsersRepository

type ManageUsersService* = ref object
  repository: ManegeUserRepository


proc newManageUsersService*():ManageUsersService =
  return ManageUsersService(
    repository: newManegeUserRepository()
  )

proc index*(this:ManageUsersService): seq[JsonNode] =
  let users = this.repository.index()
  return users

proc show*(this:ManageUsersService, id: int): JsonNode =
  let user = this.repository.show(id)
  return user
