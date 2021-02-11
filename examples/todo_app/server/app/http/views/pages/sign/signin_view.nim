import json, tables
import ../../../../../../../../src/basolato/view
import ../../layouts/application_view


let style = block:
  var css = newCss()
  css.set("errors", "", """
    background-color: pink;
    color: red;
  """)
  css

proc impl(params:JsonNode, errors:JsonNode):string = tmpli html"""
$(style.define())
<section class="section">
  <div class="container is-max-desktop">
    <div class="card">
      <div class="card-header">
        <div class="card-header-title"> Todo App Sign In</div>
      </div>
      <div class="card-content">
        <form method="POST">
          $(csrfToken())

          <div class="field">
            <p class="control has-icons-left">
              <input type="text" name="email" placeholder="email" value="$(old(params, "email"))" class="input" >
              <span class="icon is-small is-left">
                <i class="fas fa-envelope"></i>
              </span>
            </p>
            $if errors.hasKey("email"){
              <ul class="$(style.get("errors"))">
                $for error in errors["email"] {
                  <li>$(error.get())</li>
                }
              </ul>
            }
          </div>

          <div class="field">
            <p class="control has-icons-left">
              <input type="password" name="password" placeholder="password" class="input" >
              <span class="icon is-small is-left">
                <i class="fas fa-lock"></i>
              </span>
            </p>
            $if errors.hasKey("password"){
              <ul class="$(style.get("errors"))">
                $for error in errors["password"] {
                  <li>$(error.get())</li>
                }
              </ul>
            }
          </div>

          <div class="field">
            <button type="submit" class="button is-primary is-light is-outlined">signin</button>
          </div>
        </form>
      </div>
      <a href="/signup">Sign up here</a>
    </div>
  </div>
</section>
"""

proc signinView*(params=newJObject(), errors=newJObject()):string =
  let title = "Sign in"
  return applicationView(title, impl(params, errors))
