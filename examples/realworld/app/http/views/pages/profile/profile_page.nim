import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../templates/user_info/user_info_template
import ../../templates/user_article_list/user_article_list_template

proc profilePageView*(context: Context): Future[Component] {.async.} =
  let userInfoSection = await userInfoTemplate(context)
  let userArticleListSection = await userArticleListTemplate(context)
  let body = block:
    tmpl"""
      <div class="profile-page">
        $(userInfoSection)

        <div class="container">
          <div class="row">
            <div class="col-xs-12 col-md-10 offset-md-1">
              $(userArticleListSection)
            </div>
          </div>
        </div>
      </div>
    """
    result
  return await appLayout(context, "Profile", body)
