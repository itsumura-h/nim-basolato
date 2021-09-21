import json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/todo/app_bar_view
import ../../layouts/todo/status_view


style "css", style:"""
<style>
  .columns {
    max-width: 100%;
    margin: auto;
  }
</style>
"""

proc impl(id, name:string, data:JsonNode):string = tmpli html"""
$(style)
<header>
  $(appBarView(name))
</header>
<main>
  <section class="columns $(style.element("columns"))">
    $for status in data["master"]["status"]{
      $(statusView(status, data))
    }
  </section>
</main>
"""

proc indexView*(id, name:string, data:JsonNode):string =
  let title = ""
  return applicationView(title, impl(id, name, data))
