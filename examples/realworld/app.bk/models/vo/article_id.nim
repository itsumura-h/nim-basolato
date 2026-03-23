import std/strutils
import ../../errors
import ./title

type ArticleId*  = object
  value*:string

proc new*(_:type ArticleId, value:string):ArticleId =
  if value.len == 0:
    raise newException(DomainError, "article id is empty")

  let value = value.toLowerAscii().replace(" ", "-")
  return ArticleId(
    value:value
  )


proc new*(_:type ArticleId, title:Title):ArticleId = 
  let value = title.value.toLowerAscii().replace(" ", "-")
  return ArticleId(
    value:value
  )
