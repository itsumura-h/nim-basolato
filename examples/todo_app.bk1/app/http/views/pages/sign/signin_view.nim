import json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style:"""
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
"""

proc impl(params, errors:JsonNode):string = tmpli html"""
$(style)
<main>
  <section class="section $(style.element("section"))">
    <form method="POST" class="box">
      $(csrfToken())
      <h2 class="title">Sign In</h2>
      <article class="field">
        <div class="controll">
          <input type="text" class="input" name="email" placeholder="email" value="$(old(params, "email"))">
        </div>
        $if errors.hasKey("email"){
          <aside>
            $for error in errors["email"]{
              <p class="help is-danger">$(error.get)</p>
            }
          </aside>
        }
      </article>
      <article class="field">
        <input type="password" class="input" name="password" placeholder="password">
        $if errors.hasKey("password"){
          <aside>
            $for error in errors["password"]{
              <p class="help is-danger">$(error.get)</p>
            }
          </aside>
        }
      </article>
      <article>
        $if errors.hasKey("error"){
          <aside>
            $for error in errors["error"]{
              <p class="help is-danger">$(error.get)</p>
            }
          </aside>
        }
      </article>
      <article class="field $(style.element("nav"))">
        <a href="/signup">Sign up here</a>
        <button type="submit" class="button is-link">Sign In</button>
      </article>
    </form>
  </section>
</main>
"""

proc signinView*(params, errors:JsonNode):string =
  let title = "Sign In"
  return applicationView(title, impl(params, errors))
