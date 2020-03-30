import basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>Sample App</h1>
<p>
  This is the home page for the
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  sample application.
</p>
"""

proc homeHtml*():string =
  applicationHtml("Home", impl())
