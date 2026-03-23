import std/times
import ../../../../models/dto/article_with_author/article_with_author_dto
import ../../islands/favorite_button/favorite_button_view_model
import ./feed_navigation/feed_navigation_view_model
import ./paginator/paginator_view_model


type Tag*  = object
  name*:string

proc new*(_:type Tag, name:string):Tag =
  return Tag(
    name:name
  )


type User*  = object
  id*:string
  name*:string
  image*:string

proc new*(_:type User, id:string, name:string, image:string):User =
  let user = User(
    id:id,
    name:name,
    image:image
  )
  return user


type Article*  = object
  id*:string
  title*:string
  description*:string
  createdAt*:string = "1970 January 1"
  user*:User
  tags*:seq[Tag]
  favoriteButtonViewModel*:FavoriteButtonViewModel

proc new*(_:type Article, dto:ArticleWithAuthorDto, favoriteButtonViewModel:FavoriteButtonViewModel):Article =
  var tags:seq[Tag]
  for row in dto.tags:
    let tag = Tag.new(row.name)
    tags.add(tag)

  let user = User.new(
    id = dto.author.id,
    name = dto.author.name,
    image = dto.author.image
  )

  return Article(
    id: dto.id,
    title: dto.title,
    description: dto.description,
    createdAt: dto.createdAt.format("yyyy MMMM d"),
    user: user,
    tags: tags,
    favoriteButtonViewModel: favoriteButtonViewModel
  )


type ArticlePreviewViewModel*  = object
  articles*:seq[Article]
  paginator*:PaginatorViewModel
  feedNavbarItems*:seq[FeedNavbarViewModel]

proc new*(_:type ArticlePreviewViewModel, articles:seq[Article], paginator:PaginatorViewModel, feedNavbarItems:seq[FeedNavbarViewModel]):ArticlePreviewViewModel =
  return ArticlePreviewViewModel(
    articles:articles,
    paginator:paginator,
    feedNavbarItems:feedNavbarItems
  )


# proc new*(_:type ArticlePreviewViewModel, tagFeedDto:TagFeedDto, tagName:string, paginator:PaginatorViewModel, isLogin:bool):ArticlePreviewViewModel =
#   var articles:seq[Article]
#   for row in tagFeedDto.articlesWithAuthor:
#     let user = User.new(
#       id = row.author.id,
#       name = row.author.name,
#       image = row.author.image
#     )
#     var tags:seq[Tag]
#     for row in row.tags:
#       let tag = Tag.new(row.name)
#       tags.add(tag)

#     let article = Article.new(
#       id = row.id,
#       title = row.title,
#       description = row.description,
#       createdAt = row.createdAt.format("yyyy MMMM d"),
#       user = user,
#       tags = tags,
#       favoriteButtonViewModel = FavoriteButtonViewModel()
#     )
#     articles.add(article)

#   var feedNavbarItems = @[
#     FeedNavbar.new(
#       title = "Global Feed",
#       isActive = false,
#       hxGetUrl = "/htmx/home/global-feed",
#       hxPushUrl = "/"
#     ),
#     FeedNavbar.new(
#       title = tagName,
#       isActive = true,
#       hxGetUrl = "/htmx/tag-feed",
#       hxPushUrl = "/tag-feed/" & tagName,
#     ),
#   ]

#   if isLogin:
#     feedNavbarItems.insert(
#       FeedNavbar.new(
#         title = "Your Feed",
#         isActive = false,
#         hxGetUrl = "/htmx/home/your-feed",
#         hxPushUrl = "/your-feed"
#       ),
#       0
#     )

#   return ArticlePreviewViewModel(
#     articles:articles,
#     paginator:paginator,
#     feedNavbarItems:feedNavbarItems
#   )
