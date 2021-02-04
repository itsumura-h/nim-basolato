import json
import ../value_objects
import ../models/post/post_entity
import ../models/post/post_repository_interface


type PostUsecase* = ref object
  repository: IPostRepository

proc newPostUsecase*(repository:IPostRepository):PostUsecase =
  return PostUsecase(repository:repository)


proc store*(this:PostUsecase, userId:int, title, content:string) =
  let userId = newUserId(userId)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(userId, title, content)
  this.repository.store(post)

proc changeStatus*(this:PostUsecase, id:int, status:bool) =
  let id = newPostId(id)
  this.repository.changeStatus(id, status)

proc destroy*(this:PostUsecase, id:int) =
  let id = newPostId(id)
  this.repository.destroy(id)

proc update*(this:PostUsecase, id:int, title, content:string, isFinished:bool) =
  let postId = newPostId(id)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(postId, title, content, isFinished)
  this.repository.update(post)
