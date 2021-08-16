import asyncdispatch, json, options
import ../models/user/user_value_objects
import ../models/post/post_value_objects
import ../models/post/post_entity
import ../models/post/post_repository_interface
import ../models/post/post_query_service_interface
import ../../di_container

type PostUsecase* = ref object
  repository: IPostRepository
  queryService: IPostQueryService

proc newPostUsecase*():PostUsecase =
  result = new PostUsecase
  result.repository = di.postRepository
  result.queryService = di.postQueryService


proc getPostsByUserId*(self:PostUsecase, id:int):Future[seq[JsonNode]] {.async.} =
  return await self.queryService.getPostsByUserId(id)

proc getPostById*(self:PostUsecase, id:int):Future[Option[JsonNode]] {.async.} =
  return await self.queryService.getPostById(id)

proc store*(self:PostUsecase, userId:int, title, content:string) {.async.} =
  let userId = newUserId(userId)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(userId, title, content)
  await self.repository.store(post)

proc changeStatus*(self:PostUsecase, id:int, status:bool) {.async.} =
  let id = newPostId(id)
  await self.repository.changeStatus(id, status)

proc destroy*(self:PostUsecase, id:int) {.async.} =
  let id = newPostId(id)
  await self.repository.destroy(id)

proc update*(self:PostUsecase, id:int, title, content:string, isFinished:bool) {.async.} =
  let postId = newPostId(id)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(postId, title, content, isFinished)
  await self.repository.update(post)
