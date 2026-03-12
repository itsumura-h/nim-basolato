import std/asyncdispatch
import std/options
# import ../../models/dto/comment_list_in_article/comment_list_in_article_dto
import ../../models/dto/comment_list_in_article/comment_list_in_article_query_interface
import ../../models/dto/user/user_query_interface
from ../../models/dto/user/user_dto import UserDto
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../http/views/pages/comment/comment_view_model
import ../../di_container



type CommentListInArticlePresenter* = object
  query:ICommentListInArticleQuery
  userQuery:IUserQuery

proc new*(_:type CommentListInArticlePresenter):CommentListInArticlePresenter =
  return CommentListInArticlePresenter(
    query: di.commentListInArticleQuery,
    userQuery: di.userQuery
  )


proc invoke*(self:CommentListInArticlePresenter, articleId:string, loginUserId:Option[string]):Future[CommentViewModel] {.async.} =
  let articleId = ArticleId.new(articleId)
  let dto = self.query.invoke(articleId).await

  let loginUser =
    if loginUserId.isSome():
      let userId = UserId.new(loginUserId.get())
      self.userQuery.invoke(userId).await.some()
    else:
      none(UserDto)
  let viewModel = CommentViewModel.new(dto, loginUser)
  return viewModel
