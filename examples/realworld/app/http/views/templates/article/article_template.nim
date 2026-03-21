import basolato/view
import ./article_template_model


proc articleTemplate*(model: ArticleTemplateModel): Component =
  tmpl"""
    <div class="container">
      <h1>$(model.article.title)</h1>

      <div class="article-meta">
        <a href="/profile/$(model.author.id)"><img src="$(model.author.image)" /></a>
        <div class="info">
          <a href="/profile/$(model.author.id)" class="author">$(model.author.name)</a>
          <span class="date">$(model.article.updatedAt)</span>
        </div>
        <form action="/article/$(model.articleId)/follow/$(model.author.id)" method="post" style="display:inline">
          $(model.csrfToken)
          <button class="btn btn-sm btn-outline-secondary $if model.author.isFollowed{active}">
            $if model.author.isFollowed{
              <i class="ion-minus-round"></i>
              &nbsp; Unfollow $(model.author.name)
            }$else{
              <i class="ion-plus-round"></i>
              &nbsp; Follow $(model.author.name)
            }
            <span class="counter">($(model.author.followerCount))</span>
          </button>
        </form>
        &nbsp;&nbsp;
        <form action="/article/$(model.articleId)/favorite" method="post" style="display:inline">
          $(model.csrfToken)
          <button class="btn btn-sm btn-outline-primary $if model.article.isFavorited{active}">
            <i class="ion-heart"></i>
            $if model.article.isFavorited{
              &nbsp; Unfavorite Post
            }$else{
              &nbsp; Favorite Post
            }
            <span class="counter">($(model.article.favoriteCount))</span>
          </button>
        </form>
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
      </div>
    </div>
  </div>

  <div class="container page">
    <div class="row article-content">
      <div class="col-md-12">
        
        $(model.article.content |raw)
        <br>

        $if model.article.tagList.len > 0{
          <ul class="tag-list">
            $for tag in model.article.tagList{
              <li class="tag-default tag-pill tag-outline">$(tag)</li>
            }
          </ul>
        }
      </div>
    </div>

    <hr />

    <div class="article-actions">
      <div class="article-meta">
        <a href="/profile/$(model.author.id)"><img src="$(model.author.image)" /></a>
        <div class="info">
          <a href="/profile/$(model.author.id)" class="author">$(model.author.name)</a>
          <span class="date">$(model.article.updatedAt)</span>
        </div>

        <form action="/article/$(model.articleId)/follow/$(model.author.id)" method="post" style="display:inline">
          $(model.csrfToken)
          <button class="btn btn-sm btn-outline-secondary $if model.author.isFollowed{active}">
            $if model.author.isFollowed{
              <i class="ion-minus-round"></i>
              &nbsp; Unfollow $(model.author.name)
            }$else{
              <i class="ion-plus-round"></i>
              &nbsp; Follow $(model.author.name)
            }
          </button>
        </form>
        &nbsp;
        <form action="/article/$(model.articleId)/favorite" method="post" style="display:inline">
          $(model.csrfToken)
          <button class="btn btn-sm btn-outline-primary $if model.article.isFavorited{active}">
            <i class="ion-heart"></i>
            $if model.article.isFavorited{
              &nbsp; Unfavorite Article
            }$else{
              &nbsp; Favorite Article
            }
            <span class="counter">($(model.article.favoriteCount))</span>
          </button>
        </form>
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
      </div>
    </div>

    <link rel="stylesheet" href="https://unpkg.com/prismjs@1.29.0/themes/prism-okaidia.min.css">
    <script src="https://unpkg.com/prismjs@1.29.0/components/prism-core.min.js"></script>
    <script src="https://unpkg.com/prismjs@1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
  """
