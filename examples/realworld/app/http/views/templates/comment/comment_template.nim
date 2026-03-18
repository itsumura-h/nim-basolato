import basolato/view
import ../../components/comment/comment_component
import ./comment_template_model


proc commentTemplate*(model: CommentTemplateModel): Component =
  tmpl"""
    <div class="row">
      <div class="col-xs-12 col-md-8 offset-md-2">

        $if model.isLogin{
          <form class="card comment-form" action="/article/$(model.articleId)/comments" method="post">
            <div class="card-block">
              $(model.csrfToken)
              <textarea class="form-control" placeholder="Write a comment..." rows="3" name="body"></textarea>
            </div>
            <div class="card-footer">
              <img src="$(model.loginUserImage)" class="comment-author-img" />
              <button class="btn btn-sm btn-primary">Post Comment</button>
            </div>
          </form>
        }

        $for comment in model.commentList{
          $(commentComponent(comment))
        }

      </div>
    </div>
  """
