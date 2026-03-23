import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model
import ../../templates/feed/global_feed_template
import ../../templates/feed/global_feed_template_model
import ../../templates/feed/your_feed_template
import ../../templates/feed/your_feed_template_model
import ../../templates/feed/tag_feed_template
import ../../templates/feed/tag_feed_template_model
import ../../templates/popular_tags/popular_tags_template
import ../../templates/popular_tags/popular_tags_template_model


proc homePageBody(feedSection: Component, popularTagsSection: Component): Component =
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
              $(feedSection)
            </div>

            <div class="col-md-3">
              $(popularTagsSection)
            </div>
          </div>
        </div>
      </div>
    """

proc homePageView*(context: Context): Future[Component] {.async.} =
  let feedSection =
    if context.request.url.path == "/":
      let model = await GlobalFeedTemplateModel.new(context)
      globalFeedTemplate(model)
    elif context.request.url.path == "/your-feed":
      let model = await YourFeedTemplateModel.new(context)
      yourFeedTemplate(model)
    else:
      let model = await TagFeedTemplateModel.new(context)
      tagFeedTemplate(model)

  let popularTagsModel = PopularTagsTemplateModel.new(context).await
  let popularTagsSection = popularTagsTemplate(popularTagsModel)

  let body = homePageBody(feedSection, popularTagsSection)

  let appLayoutModel = AppLayoutModel.new(context, "Home", body).await
  return appLayout(appLayoutModel)
