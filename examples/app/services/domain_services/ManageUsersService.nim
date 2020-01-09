from json import JsonNode

# repository
import ../../repositories/ManageUsersRepository

proc index*(): seq[JsonNode] =
  let users = ManageUsersRepository.index()
  return users


proc show*(id: int): JsonNode =
  let user = ManageUsersRepository.show(id)
  return user
