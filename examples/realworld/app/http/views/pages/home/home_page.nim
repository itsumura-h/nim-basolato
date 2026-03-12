import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/feed/global_feed_template
import ../../templates/feed/your_feed_template
import ../../templates/feed/tag_feed_template
import ../../templates/popular_tags/popular_tags_template
import ../../templates/feed/feed_template_model


proc impl(): Future[Component] {.async.} =
  let context = context()
  let feedTemplate =
    if context.request.url.path == "/":
      globalFeedTemplate().await
    elif context.request.url.path == "/your-feed":
      yourFeedTemplate().await
    else:
      tagFeedTemplate().await

  tmpl"""
    <div class="home-page">
      <div class="banner">
        <div class="container">
          <h1 class="logo-font">conduit</h1>
          <p>A place to share your knowledge.</p>
        </div>
      </div>

      <div class="container page">
        <div class="row">
          <div class="col-md-9">
            $(feedTemplate)
          </div>

          <div class="col-md-3">
            $(popularTagsTemplate().await)
          </div>
        </div>
      </div>
    </div>
  """

proc homePage*(): Future[Component] {.async.} =
  return appLayout("Home", impl().await).await
