import basolato/view
import ../../layouts/app/app_view_model
import ../../layouts/app/app_view
import ./home_view_model


proc impl(viewModel:HomeViewModel):Component =
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
            <div class="feed-toggle">
              <ul id="feed-navigation" class="nav nav-pills outline-active"></ul>
            </div>

            <div id="feed-article-preview"
              hx-trigger="load"

              $if viewModel.feedType == tag{
                hx-get="/islandndnd/home/tag-feed/$(viewModel.tagName)$if viewModel.hasPage{?page=$(viewModel.page)}"
              }$elif viewModel.feedType == personal{
                hx-get="/island/home/your-feed$if viewModel.hasPage{?page=$(viewModel.page)}"
              }$else{
                hx-get="/island/home/global-feed$if viewModel.hasPage{?page=$(viewModel.page)}"
              }
            ></div>

            <nav id="feed-pagination"></nav>
          </div>

          <div class="col-md-3">
            <div class="sidebar">
              <p>Popular Tags</p>

              <div id="popular-tag-list" class="tag-list"
                hx-trigger="load"
                hx-get="/island/home/tag-list"
              ></div>
            </div>
          </div>

        </div>
      </div>
    </div>
  """


proc homeView*(appViewModel:AppViewModel, viewModel:HomeViewModel):Component =
  return appView(appViewModel, impl(viewModel))

proc islandHomeView*(viewModel:HomeViewModel):Component =
  return impl(viewModel)
