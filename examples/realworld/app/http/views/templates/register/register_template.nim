import std/asyncdispatch
import basolato/view
import ./register_template_model


proc registerTemplate*():Future[Component] {.async.} =
  let model = RegisterTemplateModel.new().await
  
  tmpl"""
    <div class="auth-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-6 offset-md-3 col-xs-12">
            <h1 class="text-xs-center">Sign up</h1>
            <p class="text-xs-center">
              <a href="/login">Have an account?</a>
            </p>

              <ul class="error-messages">
                $for error in model.errors{
                  <li>$(error)</li>
                }
              </ul>

            <form method="post" action="/register">
              $(csrfToken())
              <fieldset class="form-group">
                <input
                  class="form-control form-control-lg"
                  type="text"
                  placeholder="Username"
                  name="name"
                  value="$( model.name )"
                />
              </fieldset>
              <fieldset class="form-group">
                <input
                  class="form-control form-control-lg"
                  type="text"
                  placeholder="Email"
                  name="email"
                  value="$( model.email )"
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
              <button class="btn btn-lg btn-primary pull-xs-right">Sign up</button>
            </form>
          </div>
        </div>
      </div>
    </div>
  """
