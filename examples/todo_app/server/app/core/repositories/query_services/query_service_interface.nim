import json, options, asyncdispatch

type IQueryService* = tuple
  getPostsByUserId: proc(id:int):Future[seq[JsonNode]]
  getPostById: proc(id:int):Future[Option[JsonNode]]
