import json
import ../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>About</h1>
<p>
  <a href="https://railstutorial.jp/">Ruby on Rails Tutorial</a>
  is a <a href="https://railstutorial.jp/#ebook">book</a> and
  <a href="https://railstutorial.jp/#screencast">screencast</a>
  to teach web development with
  <a href="http://rubyonrails.org/">Ruby on Rails</a>.
  This is the sample application for the tutorial.
</p>
"""

proc aboutHtml*(this:View):string =
  this.applicationHtml("About", impl())
