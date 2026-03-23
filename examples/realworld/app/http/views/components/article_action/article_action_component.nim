import basolato/view
import ./article_action_component_model

proc articleFollowAction*(model: ArticleActionComponentModel, position: string): Component =
  tmpl"""
    $if not model.isAuthor{
      <form action="/article/$(model.articleId)/follow/$(model.authorId)" method="post" style="display:inline">
        $(model.csrfToken)
        <button class="btn btn-sm btn-outline-secondary $if model.isFollowed{active}">
          $if model.isFollowed{
            <i class="ion-minus-round"></i>
            &nbsp; Unfollow $(model.authorName)
          }$else{
            <i class="ion-plus-round"></i>
            &nbsp; Follow $(model.authorName)
          }
          <span class="counter">($(model.followerCount))</span>
        </button>
      </form>
    }
  """

proc articleFavoriteAction*(model: ArticleActionComponentModel, position: string): Component =
  let buttonText =
    if position == "banner":
      if model.isFavorited: "Unfavorite Post" else: "Favorite Post"
    else:
      if model.isFavorited: "Unfavorite Article" else: "Favorite Article"
  tmpl"""
    <form action="/article/$(model.articleId)/favorite" method="post" style="display:inline">
      $(model.csrfToken)
      <button class="btn btn-sm btn-outline-primary $if model.isFavorited{active}" $if model.isAuthor{disabled}>
        <i class="ion-heart"></i>
        &nbsp; $(buttonText)
        <span class="counter">($(model.favoriteCount))</span>
      </button>
    </form>
  """

proc articleAuthorActions*(model: ArticleActionComponentModel): Component =
  tmpl"""
    $if model.isAuthor{
      <a class="btn btn-sm btn-outline-secondary" href="/editor/$(model.articleId)">
        <i class="ion-edit"></i> Edit Article
      </a>
      <form action="/article/$(model.articleId)/delete" method="post" style="display:inline">
        $(model.csrfToken)
        <button class="btn btn-sm btn-outline-danger">
          <i class="ion-trash-a"></i> Delete Article
        </button>
      </form>
    }
  """
