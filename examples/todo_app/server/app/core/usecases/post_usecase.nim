import ../value_objects
import ../models/post/post_entity
import ../models/post/post_repository_interface


type PostUsecase* = ref object
  repository: IPostRepository

proc newPostUsecase*(repository:IPostRepository):PostUsecase =
  return PostUsecase(repository:repository)


proc store*(self:PostUsecase, userId:int, title, content:string) =
  let userId = newUserId(userId)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(userId, title, content)
  self.repository.store(post)

proc changeStatus*(self:PostUsecase, id:int, status:bool) =
  let id = newPostId(id)
  self.repository.changeStatus(id, status)

proc destroy*(self:PostUsecase, id:int) =
  let id = newPostId(id)
  self.repository.destroy(id)

proc update*(self:PostUsecase, id:int, title, content:string, isFinished:bool) =
  let postId = newPostId(id)
  let title = newPostTitle(title)
  let content = newPostContent(content)
  let post = newPost(postId, title, content, isFinished)
  self.repository.update(post)
