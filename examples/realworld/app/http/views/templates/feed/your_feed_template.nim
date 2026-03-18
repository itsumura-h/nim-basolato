import basolato/view
import ../../components/feed_article/feed_article_component
import ../../components/paginator/paginator_component
import ./your_feed_template_model


proc yourFeedTemplate*(model: YourFeedTemplateModel): Component =
  tmpl"""
    <div class="feed-toggle">
      <ul class="nav nav-pills outline-active">
        $if model.isLogin{
          <li class="nav-item">
            <a class="nav-link active" href="/your-feed">Your Feed</a>
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
