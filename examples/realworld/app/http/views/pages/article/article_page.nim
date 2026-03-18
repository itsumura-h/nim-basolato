import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model
import ../../templates/article/article_template
import ../../templates/article/article_template_model
import ../../templates/comment/comment_template
import ../../templates/comment/comment_template_model


proc articlePageBody(articleSection: Component, commentSection: Component): Component =
  tmpl"""
    <div class="article-page">
      <div class="banner">
        $(articleSection)
        $(commentSection)
      </div>
    </div>
  """

proc articlePageView*(context: Context): Future[Component] {.async.} =
  let articleModel = ArticleTemplateModel.new(context).await
  let articleSection = articleTemplate(articleModel)
  let commentModel = CommentTemplateModel.new(context).await
  let commentSection = commentTemplate(commentModel)
  let body = articlePageBody(articleSection, commentSection)
  let appLayoutModel = AppLayoutModel.new(context, "Article", body).await
  return appLayout(appLayoutModel)
