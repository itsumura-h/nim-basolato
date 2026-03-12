import basolato/view
import ./navbar_view_model


proc navbarView*(viewModel:NavbarViewModel):Component =
  tmpl"""
    <nav class="navbar navbar-light">
      <div class="container">
        <a class="navbar-brand" href="/">conduit</a>
        <ul class="nav navbar-nav pull-xs-right">
          <li class="nav-item">
            <!-- Add "active" class when you're on that page" -->
            <a
              class="nav-link active"
              href="/"
              hx-push-url="/"
              hx-get="/island/home"
              hx-target="#app-body"
            >
              Home
            </a>
          </li>
          $if not viewModel.isLogin{
            <li class="nav-item">
              <a id="nav-link-sign-in"
                class="nav-link" 
                href="/sign-in"
                hx-push-url="/sign-in"
                hx-get="/island/sign-in"
                hx-target="#app-body"
              >
                Sign in
              </a>
            </li>
            <li class="nav-item">
              <a id="nav-link-sign-up"
                class="nav-link"
                href="/sign-up"
                hx-push-url="/sign-up"
                hx-get="/island/sign-up"
                hx-target="#app-body"
              >
                Sign up
              </a>
            </li>
          }$else{
            <li class="nav-item">
              <a
                class="nav-link"
                href="/editor"
                hx-push-url="/editor"
                hx-get="/island/editor"
                hx-target="#app-body"
              >
                <i class="ion-compose"></i>&nbsp;New Article
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="/settings"
                hx-push-url="/settings"
                hx-get="/island/settings"
                hx-target="#app-body"
              >
                <i class="ion-gear-a"></i>&nbsp;Settings
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link"
                href="/users/$(viewModel.userId)"
                hx-push-url="/users/$(viewModel.userId)"
                hx-get="/island/users/$(viewModel.userId)"
                hx-target="#app-body"
              >
                <img src="$(viewModel.image)" class="user-pic" />
                $(viewModel.userName)
              </a>
            </li>
          }
        </ul>
      </div>
    </nav>
  """
