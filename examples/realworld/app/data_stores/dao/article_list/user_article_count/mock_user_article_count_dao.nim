import std/asyncdispatch
import ../../../../models/dto/article_list/user_article_count_dao_interface


type MockUserArticleCountDao* = object of IUserArticleCountDao

proc new*(_:type MockUserArticleCountDao):MockUserArticleCountDao =
  return MockUserArticleCountDao()


method invoke*(self:MockUserArticleCountDao, userId:int):Future[int] {.async.} =
  return 0
