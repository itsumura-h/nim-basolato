import std/asyncdispatch
import basolato/view
import ./navbar_layout_model


proc navbarLayout*():Future[Component] {.async.} =
  let model = NavbarLayoutModel.new().await
  tmpl"""
    <nav class="navbar navbar-light">
      <div class="container">
        <a class="navbar-brand"
          href="/"
          hx-push-url="/"
          hx-get="/island/home"
          hx-target="#app-body"
        >
          conduit
        </a>
        <ul class="nav navbar-nav pull-xs-right">
          <li class="nav-item">
            <a
              class="nav-link active"
              href="/"
            >
              Home
            </a>
          </li>
          $if not model.isLogin{
            <li class="nav-item">
              <a id="nav-link-sign-in"
                class="nav-link active"
                href="/login"
              >
                Sign in
              </a>
            </li>
            <li class="nav-item">
              <a id="nav-link-sign-up"
                class="nav-link active"
                href="/register"
              >
                Sign up
              </a>
            </li>
          }$else{
            <li class="nav-item">
              <a
                class="nav-link active"
                href="/editor"
              >
                <i class="ion-compose"></i>&nbsp;New Article
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link active"
                href="/settings"
              >
                <i class="ion-gear-a"></i>&nbsp;Settings
              </a>
            </li>
            <li class="nav-item">
              <a
                class="nav-link active"
                href="/users/$(model.userId)"
              >
                <img src="$(model.image)" class="user-pic" />
                $(model.userName)
              </a>
            </li>
          }
        </ul>
      </div>
    </nav>
  """
