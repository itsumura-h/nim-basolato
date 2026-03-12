import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/user_info/user_info_template
import ../../templates/user_article_list/user_article_list_template

proc impl():Future[Component] {.async.} =
  tmpl"""
    <div class="profile-page">
      $(userInfoTemplate().await)

      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-10 offset-md-1">
            $(userArticleListTemplate().await)
          </div>
        </div>
      </div>
    </div>
  """


proc profilePage*():Future[Component] {.async.} =
  return appLayout("Profile", impl().await).await
