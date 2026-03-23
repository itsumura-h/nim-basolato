import std/asyncdispatch
import std/strformat
import ../../models/dto/article_with_author/your_feed_article_list_query_interface
import ../../models/dto/paginator/your_feed_article_list_paginator_query_interface
import ../../models/dto/favorite_button/favorite_button_query_interface
import ../../models/vo/article_id
import ../../models/vo/user_id
import ../../http/views/islands/article_preview/article_preview_view_model
import ../../http/views/islands/article_preview/paginator/paginator_view_model
import ../../http/views/islands/article_preview/feed_navigation/feed_navigation_view_model
import ../../http/views/islands/favorite_button/favorite_button_view_model
import ../../di_container


type YourFeedArticleListPresenter* = object
  yourFeedArticleListQuery:IYourFeedArticleListQuery
  paginatorQuery: IYourFeedArticleListPaginatorQuery
  favoriteButtonQuery: IFavoriteButtonQuery

proc new*(_:type YourFeedArticleListPresenter):YourFeedArticleListPresenter =
  return YourFeedArticleListPresenter(
    yourFeedArticleListQuery: di.yourFeedArticleListQuery,
    paginatorQuery: di.yourFeedPaginatorQuery,
    favoriteButtonQuery: di.favoriteButtonQuery
  )


proc invoke*(
  self:YourFeedArticleListPresenter,
  loginUserId:string,
  page:int,
):Future[ArticlePreviewViewModel] {.async.} =
  const display = 5
  let offset = (page - 1) * display
  let loginUserId = UserId.new(loginUserId)
  let articleWithAuthorDtoList = self.yourFeedArticleListQuery.invoke(loginUserId, offset, display).await

  var articleList:seq[Article]
  for articleWithAuthorDto in articleWithAuthorDtoList:
    let articleId = ArticleId.new(articleWithAuthorDto.id)
    let favoriteButtonDto = self.favoriteButtonQuery.invoke(articleId, loginUserId).await
    let favoriteButtonViewModel = FavoriteButtonViewModel.new(favoriteButtonDto)
    articleList.add(
      Article.new(articleWithAuthorDto, favoriteButtonViewModel)
    )

  let paginatorDto = self.paginatorQuery.invoke(loginUserId, page, display).await
  let paginatorViewModel = PaginatorViewModel.new(paginatorDto, &"/island/home/your-feed")

  var feedNavbarViewModelList = @[
    FeedNavbarViewModel.new(
      title = "Your Feed",
      isActive = true,
      hxGetUrl = "/island/home/your-feed",
      hxPushUrl = "/your-feed"
    ),
    FeedNavbarViewModel.new(
      title = "Global Feed",
      isActive = false,
      hxGetUrl = "/island/home/global-feed",
      hxPushUrl = "/"
    )
  ]

  let viewModel = ArticlePreviewViewModel.new(articleList, paginatorViewModel, feedNavbarViewModelList)
  return viewModel
