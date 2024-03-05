import
  std/asyncdispatch,
  std/json,
  ../../../../../../../src/basolato/view,
  ../../layouts/application_view


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
          <h2 class="bulma-title">Sign In</h2>
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
          <article>
            $if errors.hasKey("error"){
              <aside>
                $for error in errors["error"]{
                  <p class="bulma-help bulma-is-danger">$(error)</p>
                }
              </aside>
            }
          </article>
          <article class="bulma-field $(style.element("nav"))">
            <a href="/signup">Sign up here</a>
            <button type="submit" class="bulma-button bulma-is-link">Sign In</button>
          </article>
        </form>
      </section>
    </main>
    """

proc signinView*(params, errors:JsonNode):Future[Component] {.async.} =
  let title = "Sign In"
  return applicationView(title, impl(params, errors).await)
