import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/article/article_template
import ../../templates/comment/comment_template


proc impl():Future[Component] {.async.} =
  tmpl"""
    <div class="article-page">
      <div class="banner">
        $(articleTemplate().await)
        $(commentTemplate().await)
      </div>
    </div>
  """


proc articlePage*():Future[Component] {.async.} =
  return appLayout("Article", impl().await).await
