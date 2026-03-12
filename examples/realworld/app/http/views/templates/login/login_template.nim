import std/asyncdispatch
import basolato/view
import ./login_template_model


proc loginTemplate*():Future[Component] {.async.} =
  let model = LoginTemplateModel.new().await

  tmpl"""
    <div class="auth-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Sign in</h1>
            <p class="text-xs-center">
              <a href="/register">Need an account?</a>
            </p>

            <ul class="error-messages">
              $for error in model.errors{
                <li>$(error)</li>
              }
            </ul>

            <form method="post" action="/login">
              $(csrfToken())
              <fieldset class="form-group">
                <input
                  class="form-control form-control-lg"
                  type="text"
                  placeholder="Email"
                  name="email"
                  value="$(model.email)"
                />
              </fieldset>
              <fieldset class="form-group">
                <input
                  class="form-control form-control-lg"
                  type="password"
                  placeholder="Password"
                  name="password"
                />
              </fieldset>
              <button class="btn btn-lg btn-primary pull-xs-right">Sign in</button>
            </form>
          </div>
          </div>
        </div>
      </div>
    </div>
  """
