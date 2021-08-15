import asyncdispatch
import ../models/user/user_value_objects
import ../models/post/post_value_objects
import ../models/post/post_entity
import ../models/post/post_repository_interface


type PostUsecase* = ref object
  repository: IPostRepository

proc newPostUsecase*(repository:IPostRepository):PostUsecase =
  return PostUsecase(repository:repository)


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
