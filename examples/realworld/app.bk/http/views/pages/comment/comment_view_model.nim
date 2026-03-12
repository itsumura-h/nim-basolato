import std/times
import std/options
import std/sequtils
from ../../../../models/dto/comment_list_in_article/comment_list_in_article_dto import CommentDto, CommentListInArticleDto
from ../../../../models/dto/user/user_dto import UserDto
import ./card/card_view_model
import ./form/form_view_model


type CommentViewModel*  = object
  cardList*:seq[CardViewModel]
  form*:FormViewModel
  isLogin*:bool

proc new*(_:type CommentViewModel, dto:CommentListInArticleDto, loginUser:Option[UserDto]):CommentViewModel =
  let cardList = dto.commentList.map(
    proc(row:CommentDto):CardViewModel =
      return CardViewModel.new(
        row.body,
        row.createdAt,
        row.user.id,
        row.user.name,
        row.user.image,
      )
  )

  let loginUserImage =
    if loginUser.isSome():
      loginUser.get().image
    else:
      ""
  
  let form = FormViewModel.new(
    dto.article.id,
    loginUserImage,
  )

  let isLogin = loginUser.isSome()
  return CommentViewModel(
    cardList:cardList,
    form:form,
    isLogin:isLogin,
  )
