import ../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>Contact</h1>
<p>
  Contact the Ruby on Rails Tutorial about the sample app at the
  <a href="https://railstutorial.jp/contact">contact page</a>.
</p>
"""

proc contactHtml*(this:View):string =
  this.applicationHtml("Contact", impl())
