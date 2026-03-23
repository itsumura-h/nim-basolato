import basolato/view
import ../../components/article_action/article_action_component_model
import ../../components/article_action/article_action_component

proc articleTurboStream*(
  model: ArticleActionComponentModel
): Component =
  let bannerFollow = articleFollowAction(model, "banner")
  let footerFollow = articleFollowAction(model, "footer")
  let bannerFavorite = articleFavoriteAction(model, "banner")
  let footerFavorite = articleFavoriteAction(model, "footer")
  tmpl"""
    <turbo-stream action="replace" target="article-follow-action-banner-$(model.articleId)">
      <template>
        <span id="article-follow-action-banner-$(model.articleId)">
          $(bannerFollow)
        </span>
      </template>
    </turbo-stream>
    <turbo-stream action="replace" target="article-follow-action-footer-$(model.articleId)">
      <template>
        <span id="article-follow-action-footer-$(model.articleId)">
          $(footerFollow)
        </span>
      </template>
    </turbo-stream>
    <turbo-stream action="replace" target="article-favorite-action-banner-$(model.articleId)">
      <template>
        <span id="article-favorite-action-banner-$(model.articleId)">
          $(bannerFavorite)
        </span>
      </template>
    </turbo-stream>
    <turbo-stream action="replace" target="article-favorite-action-footer-$(model.articleId)">
      <template>
        <span id="article-favorite-action-footer-$(model.articleId)">
          $(footerFavorite)
        </span>
      </template>
    </turbo-stream>
  """
