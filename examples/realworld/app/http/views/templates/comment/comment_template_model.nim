import std/asyncdispatch
import std/options
import std/times
import std/sequtils
import basolato/view
import ../../../../di_container
import ../../../../models/dto/user/user_dao_interface
import ../../../../models/dto/comment/comment_dao_interface
import ../../../../models/dto/comment/comment_dto
import ../../components/comment/comment_component_model


type CommentTemplateModel* = object
  commentList*:seq[CommentComponentModel]
  isLogin*:bool
  loginUserImage*:string


proc new*(_:type CommentTemplateModel, context: Context): Future[CommentTemplateModel] {.async.} =
  let isLogin = context.isLogin().await
  let loginUserId = context.get("user_id").await
  let articleId = context.params.getStr("articleId")

  let commentDao:ICommentDao = di.commentDao
  let commentDtoList = commentDao.getCommentListByArticleId(articleId).await

  let commentComponentModelList = commentDtoList.map(
    proc(commentDto: CommentDto): CommentComponentModel =
      return CommentComponentModel.new(
        authorId = commentDto.authorId,
        authorName = commentDto.authorName,
        authorImage = commentDto.authorImage,
        content = commentDto.content,
        createdAt = commentDto.createdAt.format("yyyy MMM d"),
        isAuthor = commentDto.authorId == loginUserId,
      )
  )

  let loginUserImage =
    if isLogin:
      let userDao:IUserDao = di.userDao
      let userDto = userDao.getUserById(loginUserId).await
      userDto.image
    else:
      ""

  return CommentTemplateModel(
    commentList: commentComponentModelList,
    isLogin: isLogin,
    loginUserImage: loginUserImage,
  )
