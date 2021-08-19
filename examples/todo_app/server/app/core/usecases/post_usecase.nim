import asyncdispatch, json, options
import ../models/user/user_value_objects
import ../models/post/post_value_objects
import ../models/post/post_entity
import ../models/post/post_repository_interface
import ../models/post/post_query_service_interface
import ../di_container

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
  let post = newPost(title, content, userId)
  await self.repository.create(post)

proc changeStatus*(self:PostUsecase, id:int) {.async.} =
  let id = newPostId(id)
  var post = await self.repository.getPostById(id)
  if post.isFinished:
    post.unDone()
  else:
    post.done()
  post.updateTime()
  await self.repository.update(post)

proc update*(self:PostUsecase, postId:int, title, content:string, isFinished:bool, userId:int) {.async.} =
  let postId = newPostId(postId)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let userId = newUserId(userId)
  var post = newPost(postId, title, content, isFinished, userId)
  post.updateTime()
  await self.repository.update(post)

proc destroy*(self:PostUsecase, id:int) {.async.} =
  let id = newPostId(id)
  await self.repository.destroy(id)