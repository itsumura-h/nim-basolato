import std/asyncdispatch
import basolato/view
import ./user_info_template_model

proc userInfoFollowAction*(model: UserInfoTemplateModel): Component =
  tmpl"""
    <span id="profile-follow-action-$(model.id)">
      <form action="/profile/$(model.id)/follow" method="post" style="display:inline">
        $(model.csrfToken)
        <button class="btn btn-sm btn-outline-secondary action-btn $if model.isFollowed{active}">
          $if model.isFollowed{
            <i class="ion-minus-round"></i>
            &nbsp; Unfollow $(model.name)
          }$else{
            <i class="ion-plus-round"></i>
            &nbsp; Follow $(model.name)
          }
        </button>
      </form>
    </span>
  """

proc userInfoFollowTurboStream*(model: UserInfoTemplateModel): Component =
  tmpl"""
    <turbo-stream action="replace" target="profile-follow-action-$(model.id)">
      <template>
        $(userInfoFollowAction(model))
      </template>
    </turbo-stream>
  """


proc userInfoTemplate*(model: UserInfoTemplateModel): Component =
  tmpl"""
    <div class="user-info">
      <div class="container">
        <div class="row">
          <div class="col-xs-12 col-md-10 offset-md-1">
            <img src="$(model.image)" class="user-img" />
            <h4>$(model.name)</h4>
            <p>
              $(model.bio)
            </p>
            $if model.isSameUser{
              <a href="/settings" class="btn btn-sm btn-outline-secondary action-btn">
                <i class="ion-gear-a"></i>
                &nbsp; Edit Profile Settings
              </a>
            }$else{
              $(userInfoFollowAction(model))
            }
          </div>
        </div>
      </div>
    </div>
  """


proc userInfoTemplate*(context: Context): Future[Component] {.async.} =
  let model = await UserInfoTemplateModel.new(context)
  return userInfoTemplate(model)
