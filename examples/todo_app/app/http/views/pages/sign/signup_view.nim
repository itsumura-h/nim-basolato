import asyncdispatch, json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view


proc impl(params, errors:JsonNode):Future[Component] {.async.} =
  let style = styleTmpl(Css, """
    <style>
      @media screen{
        main{
          display: flex;
          align-items: center;
        }
      }
      .section{
        margin: auto;
        min-width: 60%;
      }
      .nav{
        display: flex;
        justify-content: space-between;
      }
    </style>
  """)

  tmpli html"""
    $(style)
    <main>
      <section class="bulma-section $(style.element("section"))">
        <form method="POST" class="bulma-box">
          $(csrfToken())
          <h2 class="bulma-title">Sign Up</h2>
          <article class="bulma-field">
            <div class="bulma-controll">
              <input type="text" class="bulma-input" name="name" placeholder="name" value="$(old(params, "name"))">
            </div>
            $if errors.hasKey("name"){
              <aside>
                $for error in errors["name"]{
                  <p class="bulma-help bulma-is-danger">$(error)</p>
                }
              </aside>
            }
          </article>
          <article class="bulma-field">
            <div class="bulma-controll">
              <input type="text" class="bulma-input" name="email" placeholder="email" value="$(old(params, "email"))">
            </div>
            $if errors.hasKey("email"){
              <aside>
                $for error in errors["email"]{
                  <p class="bulma-help bulma-is-danger">$(error)</p>
                }
              </aside>
            }
          </article>
          <article class="bulma-field">
            <input type="password" class="bulma-input" name="password" placeholder="password">
            $if errors.hasKey("password"){
              <aside>
                $for error in errors["password"]{
                  <p class="bulma-help bulma-is-danger">$(error)</p>
                }
              </aside>
            }
          </article>
          <article class="bulma-field">
            <input type="password" class="bulma-input" name="password_confirm" placeholder="password confirm">
            $if errors.hasKey("password_confirm"){
              <aside>
                $for error in errors["password_confirm"]{
                  <p class="bulma-help bulma-is-danger">$(error)</p>
                }
              </aside>
            }
          </article>
          $if errors.hasKey("error"){
            <article class="bulma-field">
              $for error in errors["error"]{
                <p>$(error)</p>
              }
            </article>
          }
          </article>
          <article class="bulma-field $(style.element("nav"))">
            <a href="/signin">Sign in here</a>
            <button type="submit" class="bulma-button bulma-is-link">Sign Up</button>
          </article>
        </form>
      </section>
    </main>
  """

proc signupView*(params, errors:JsonNode):Future[string] {.async.} =
  let title = "Sign Up"
  return $applicationView(title, impl(params, errors).await)
