import basolato/view
import ./comment_component_model


proc commentComponent*(model: CommentComponentModel):Component =
  tmpl"""
    <div class="card">
      <div class="card-block">
        <p class="card-text">
          $(model.content)
        </p>
      </div>
      <div class="card-footer">
        <a href="/profile/$(model.authorId)" class="comment-author">
          <img src="$(model.authorImage)" class="comment-author-img" />
        </a>
        &nbsp;
        <a href="/profile/$(model.authorId)" class="comment-author">$(model.authorName)</a>
        <span class="date-posted">$(model.createdAt)</span>
        $if model.isAuthor{
          <form action="/article/$(model.articleId)/comments/$(model.commentId)/delete" method="post" class="mod-options">
            $(model.csrfToken)
            <button type="submit" class="btn btn-link p-0 text-danger">
              <i class="ion-trash-a"></i>
            </button>
          </form>
        }
      </div>
    </div>
  """
