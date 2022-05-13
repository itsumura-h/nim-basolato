import json, asyncdispatch


type ITodoQuery* = tuple
  getStatuses: proc():Future[seq[JsonNode]]
  getUsers: proc():Future[seq[JsonNode]]
  getTodoList: proc():Future[seq[JsonNode]]
