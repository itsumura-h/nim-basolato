import json

type IQueryService* = tuple
  getPostsByUserId: proc(id:int):seq[JsonNode]
  getPostByUserId: proc(id:int):JsonNode
