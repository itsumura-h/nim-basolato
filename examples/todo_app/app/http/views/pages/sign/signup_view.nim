import basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl():string = tmpli html"""
$(style)
<main>
  <section>
    <form method="POST">
      $(csrfToken())
      <header>
        <h2>Sign Up</h2>
      </header>
      <input type="text" name="name" placeholder="name">
      <input type="text" name="email" placeholder="email">
      <input type="password" name="password" placeholder="password">
      <button type="submit">Sign Up</button>
      <p>
        <a href="/signin">Sign in here</a>
      </p>
    </form>
  </section>
</main>
"""

proc signupView*():string =
  let title = "Sign Up"
  return applicationView(title, impl())
