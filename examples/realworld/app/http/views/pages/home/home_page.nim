import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/feed/global_feed_template
import ../../templates/feed/your_feed_template
import ../../templates/feed/tag_feed_template
import ../../templates/popular_tags/popular_tags_template


proc homePageView*(context: Context): Future[Component] {.async.} =
  let feedTemplate =
    if context.request.url.path == "/":
      await globalFeedTemplate(context)
    elif context.request.url.path == "/your-feed":
      await yourFeedTemplate(context)
    else:
      await tagFeedTemplate(context)

  let popularTagsSection = await popularTagsTemplate(context)

  let page = block:
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
              $(popularTagsSection)
            </div>
          </div>
        </div>
      </div>
    """
    result

  return await appLayout(context, "Home", page)
