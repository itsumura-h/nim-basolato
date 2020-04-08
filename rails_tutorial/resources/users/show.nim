import json, md5
import basolato/view
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

proc showHtml*(user:JsonNode):string =
  applicationHtml(user["name"].getStr, impl(user))
