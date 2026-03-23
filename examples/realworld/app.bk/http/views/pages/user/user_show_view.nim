import basolato/view
import ../../layouts/app/app_view_model
import ../../layouts/app/app_view
import ../../islands/follow_button/follow_button_view
import ./user_show_view_model


proc impl(viewModel:UserShowViewModel):Component =
  tmpl"""
    <div class="profile-page">
      <div class="user-info">
        <div class="container">
          <div class="row">

            <div class="col-xs-12 col-md-10 offset-md-1">
              <img src="$(viewModel.user.image)" class="user-img" />
              <h4>$(viewModel.user.name)</h4>
              <p>$(viewModel.user.bio)</p>

              $if viewModel.user.isSelf{
                <a class="btn btn-sm btn-outline-secondary action-btn"
                  href="/settings"
                  hx-push-url="/settings"
                  hx-get="/island/settings"
                  hx-target="#app-body"
                >
                  <i class="ion-ios-gear"></i>
                  &nbsp;
                  Edit Profile Settings</span>
                </a>
              }$else{
                $(followButtonView(viewModel.followButtonViewModel))
              }
            </div>

          </div>
        </div>
      </div>

       <div class="container page">
        <div class="row">

          <div class="col-md-9">
            <div class="feed-toggle">
              <ul id="feed-navigation" class="nav nav-pills outline-active"></ul>
            </div>

            <div id="feed-article-preview"
              hx-trigger="load"

              $if viewModel.loadFavorites{
                hx-get="/island/users/$(viewModel.user.id)/favorites$if viewModel.hasPage{?page=$(viewModel.page)}"
              }$else{
                hx-get="/islandnd/users/$(viewModel.user.id)/articles$if viewModel.hasPage{?page=$(viewModel.page)}"
              }
            ></div>

            <nav id="feed-pagination"></nav>
          </div>
        </div>
      </div>
    </div>
  """

proc userShowView*(appViewModel:AppViewModel, viewModel:UserShowViewModel):Component =
  appView(appViewModel, impl(viewModel))


proc islandUserShowView*(viewModel:UserShowViewModel):Component =
  impl(viewModel)
