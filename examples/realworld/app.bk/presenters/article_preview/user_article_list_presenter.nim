import std/asyncdispatch
import std/strformat
import ../../models/dto/user/user_query_interface
import ../../models/dto/article_with_author/user_article_list_query_interface
import ../../models/dto/paginator/user_article_list_paginator_query_interface
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../http/views/islands/article_preview/article_preview_view_model
import ../../http/views/islands/article_preview/paginator/paginator_view_model
import ../../http/views/islands/article_preview/feed_navigation/feed_navigation_view_model
import ../../http/views/islands/favorite_button/favorite_button_view_model
import ../../di_container


type UserArticleListPresenter* = object
  userQuery:IUserQuery
  userArticleListQuery:IUserArticleListQuery
  paginatorQuery: IUserArticleListPaginatorQuery
  favoriteButtonQuery: IFavoriteButtonQuery

proc new*(_:type UserArticleListPresenter):UserArticleListPresenter =
  return UserArticleListPresenter(
    userQuery: di.userQuery,
    userArticleListQuery: di.userArticleListQuery,
    paginatorQuery: di.userArticleListPaginatorQuery,
    favoriteButtonQuery: di.favoriteButtonQuery
  )


proc invoke*(
  self:UserArticleListPresenter,
  page:int,
  userId:string,
  isLogin:bool,
  loginUserId:string
):Future[ArticlePreviewViewModel] {.async.} =
  const display = 5
  let offset = (page - 1) * display
  let userId = UserId.new(userId)
  let loginUserId = UserId.new(loginUserId)

  let articleWithAuthorDtoList = self.userArticleListQuery.invoke(userId, offset, display).await
  echo "articleWithAuthorDtoList.len: ",articleWithAuthorDtoList.len 

  var articleList:seq[Article]
  for articleWithAuthorDto in articleWithAuthorDtoList:
    let articleId = ArticleId.new(articleWithAuthorDto.id)

    let favoriteButtonDto =
      if isLogin:
        self.favoriteButtonQuery.invoke(articleId, loginUserId).await
      else:
        self.favoriteButtonQuery.invoke(articleId).await

    let favoriteButtonViewModel = FavoriteButtonViewModel.new(favoriteButtonDto)
    articleList.add(
      Article.new(articleWithAuthorDto, favoriteButtonViewModel)
    )

  let paginatorDto = self.paginatorQuery.invoke(loginUserId, page, display).await
  let paginatorViewModel = PaginatorViewModel.new(paginatorDto, &"/island/users/{userId.value}/articles")

  var feedNavbarViewModelList = @[
    FeedNavbarViewModel.new(
      title = "My Articles",
      isActive = true,
      hxGetUrl = &"/islandndnd/user/{userId.value}",
      hxPushUrl = &"/user/{userId.value}"
    ),
    FeedNavbarViewModel.new(
      title = "Favorited Articles",
      isActive = false,
      hxGetUrl = &"/islandndndnd/users/{userId.value}/favorites",
      hxPushUrl = &"/users/{userId.value}/favorites"
    )
  ]

  let viewModel = ArticlePreviewViewModel.new(articleList, paginatorViewModel, feedNavbarViewModelList)
  return viewModel
