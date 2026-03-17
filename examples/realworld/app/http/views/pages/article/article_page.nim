import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/article/article_template
import ../../templates/comment/comment_template

proc articlePageView*(context: Context): Future[Component] {.async.} =
  let articleSection = await articleTemplate(context)
  let commentSection = await commentTemplate()
  let body = block:
    tmpl"""
      <div class="article-page">
        <div class="banner">
          $(articleSection)
          $(commentSection)
        </div>
      </div>
    """
    result
  return await appLayout(context, "Article", body)
