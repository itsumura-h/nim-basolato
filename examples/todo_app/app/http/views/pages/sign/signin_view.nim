import json
import basolato/view
import ../../layouts/application_view

style "css", style:"""
.errors {
  background-color: pink;
  color: red;
}
"""

proc impl(params, errors:JsonNode):string = tmpli html"""
$(style)
<main>
  <section>
    <form method="POST">
      $(csrfToken())
      <header>
        <h2>Sign In</h2>
      </header>
      <input type="text" name="email" placeholder="email" value="$(old(params, "email"))">
      $if errors.hasKey("email"){
        <ul class="$(style.get("errors"))">
          $for error in errors["email"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
      <input type="password" name="password" placeholder="password">
      $if errors.hasKey("password"){
        <ul class="$(style.get("errors"))">
          $for error in errors["password"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
      $if errors.hasKey("error"){
        <ul class="$(style.get("errors"))">
          $for error in errors["error"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
      <button type="submit">Sign In</button>
      <p>
        <a href="/signup">Sign up here</a>
      </p>
    </form>
  </section>
</main>
"""

proc signinView*(params, errors:JsonNode):string =
  let title = "Sign In"
  return applicationView(title, impl(params, errors))
