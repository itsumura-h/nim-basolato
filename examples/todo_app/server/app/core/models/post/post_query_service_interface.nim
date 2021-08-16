import asyncdispatch, json, options

type IPostQueryService* = tuple
  getPostsByUserId: proc(id:int):Future[seq[JsonNode]]
  getPostById: proc(id:int):Future[Option[JsonNode]]
