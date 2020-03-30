import basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<div class="center jumbotron">
  <h1>Welcome to the Sample App</h1>

  <h2>
    This is the home page for the
    <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
    sample application.
  </h2>

  <a href="#" class="btn btn-lg btn-primary">Sign up now!</a>
</div>

<a href="http://rubyonrails.org/"><img src="https://railstutorial.jp/rails.png" alt="Rails logo"></img></a>
"""

proc homeHtml*():string =
  applicationHtml("", impl())
