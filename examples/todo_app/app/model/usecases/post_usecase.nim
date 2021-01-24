import json
import ../value_objects
include ../di_container
import ../aggregates/post/post_repository_interface


type PostUsecase* = ref object
  queryService: QueryService
  repository: IPostRepository

proc newPostUsecase*():PostUsecase =
  return PostUsecase()


proc store*(this:PostUsecase, userId:int, title, content:string) =
  let userId = newUserId(userId)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  this.repository.store(userId, title, content)

proc changeStatus*(this:PostUsecase, id:int, status:bool) =
  let id = newPostId(id)
  this.repository.changeStatus(id, status)

proc destroy*(this:PostUsecase, id:int) =
  let id = newPostId(id)
  this.repository.destroy(id)

proc update*(this:PostUsecase, id:int, title, content:string, isFinished:bool) =
  let id = newPostId(id)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  this.repository.update(id, title, content, isFinished)
