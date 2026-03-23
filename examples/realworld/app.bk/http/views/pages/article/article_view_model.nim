import std/times
import std/options
import std/sequtils
import ../../../../models/dto/article_detail/article_detail_dto
import ../../../../models/dto/favorite_button/favorite_button_dto
import ../../../../models/dto/follow_button/follow_button_dto
import ../../../../models/vo/user_id
import ./favorite_button/favorite_button_in_article_view_model
import ./follow_button/follow_button_view_model
import ./edit_button/edit_button_view_model
import ./delete_button/delete_button_view_model


type Tag*  = object
  tagId*:string
  articleId*:string
  tagName*:string

proc new*(_:type Tag, tagId:string, articleId:string, tagName:string):Tag =
  return Tag(
    tagId:tagId,
    articleId:articleId,
    tagName:tagName
  )


type Article*  = object
  id*:string
  title*:string
  description*:string
  body*:string
  createdAt*:string = "1970 January 1st"
  tags*:seq[Tag]

proc new*(_:type Article, id, title, description, body:string, createdAt:DateTime, tags:seq[Tag]):Article =
  let createdAt = createdAt.format("MMMM d")

  return Article(
    id:id,
    title:title,
    description:description,
    body:body,
    createdAt:createdAt,
    tags:tags,
  )


type User*  = object
  id*:string
  name*:string
  image*:string

proc new*(_:type User, id, name, image:string):User =
  return User(
    id:id,
    name:name,
    image:image,
  )


type ArticleViewModel*  = object
  article*:Article
  user*:User
  isAuthor*:bool
  favoriteButtonViewModel*:Option[FavoriteButtonInArticleViewModel]
  followButtonViewModel*:Option[FollowButtonViewModel]
  editButtonViewModel*:Option[EditButtonViewModel]
  deleteButtonViewModel*:Option[DeleteButtonViewModel]

proc new*(
  _:type ArticleViewModel,
  articleDto:ArticleDetailDto,
  favoriteButtonDto: FavoriteButtonDto,
  followButtonDto: FollowButtonDto,
  loginUserId:Option[UserId],
):ArticleViewModel =
  let tags = articleDto.tags.map(
    proc(tag:TagDto):Tag =
      return Tag.new(
        tag.id,
        articleDto.id,
        tag.name
      )
  )
  let article = Article.new(
    articleDto.id,
    articleDto.title,
    articleDto.description,
    articleDto.body,
    articleDto.createdAt,
    tags,
  )
  let author = User.new(
    articleDto.author.id,
    articleDto.author.name,
    articleDto.author.image,
  )

  let isAuthor = (loginUserId.isSome()) and (author.id == loginUserId.get().value)

  let favoriteButtonViewModel =
    if isAuthor:
      none(FavoriteButtonInArticleViewModel)
    else:
      FavoriteButtonInArticleViewModel.new(favoriteButtonDto).some()

  let followButtonViewModel = 
    if isAuthor:
      none(FollowButtonViewModel)
    else:
      FollowButtonViewModel.new(followButtonDto, true).some()

  let editButtonViewModel =
    if isAuthor:
      EditButtonViewModel.new(articleDto.id).some()
    else:
      none(EditButtonViewModel)

  let deleteButtonViewModel =
    if isAuthor:
      DeleteButtonViewModel.new(articleDto.id).some()
    else:
      none(DeleteButtonViewModel)

  return ArticleViewModel(
    article:article,
    user:author,
    isAuthor:isAuthor,
    followButtonViewModel:followButtonViewModel,
    favoriteButtonViewModel:favoriteButtonViewModel,
    editButtonViewModel: editButtonViewModel,
    deleteButtonViewModel: deleteButtonViewModel,
  )
