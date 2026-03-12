import ../../libs/uuid

type ArticleId* = object
  value*:string

proc new*(_:type ArticleId):ArticleId =
  return ArticleId(value: genUuid())

proc new*(_:type ArticleId, value:string):ArticleId =
  return ArticleId(value: value)
