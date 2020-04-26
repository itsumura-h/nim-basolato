import json
import ../../../src/basolato/view
import ../layouts/application
import ../helper

proc impl(user:JsonNode):string = tmpli html"""
<div class="row">
  <aside class="col-md-4">
    <section class="user_info">
      <h1>
        $(gravatar_for(user))
        $(user["name"].get)
      </h1>
    </section>
  </aside>
</div>
"""

proc showHtml*(this:View, user=newJObject(), flash=newJObject()):string =
  this.applicationHtml(user["name"].getStr, impl(user), flash)
