import basolato/view
import ../layouts/application

proc impl*():string = tmpli html"""
<h1>Sign up</h1>
<p>This will be a signup page for new users.</p>
"""

proc createHtml*():string =
  applicationHtml("Sign up", impl())
