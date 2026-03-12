import basolato/view
import ../../../../presenters/feed/tag_feed_presenter
import ../../components/feed_article/feed_article_component
import ../../components/paginator/paginator_component
import ./feed_template_model


proc tagFeedTemplate*():Future[Component] {.async.} =
  let context = context()
  let tagName = context.params.getStr("tag")

  let presenter = TagFeedPresenter.new()
  let model = presenter.invoke().await

  tmpl"""
    <div class="feed-toggle">
      <ul class="nav nav-pills outline-active">
        <li class="nav-item">
          <a class="nav-link active" href="">$(tagName)</a>
        </li>
        $if model.isLogin{
          <li class="nav-item">
            <a class="nav-link" href="/your-feed">Your Feed</a>
          </li>
        }
        <li class="nav-item">
          <a class="nav-link" href="/">Global Feed</a>
        </li>
      </ul>
    </div>

    $for article in model.articleList{
      $(feedArticleComponent(article))
    }

    $(paginatorComponent(model.paginatorModel))
  """
