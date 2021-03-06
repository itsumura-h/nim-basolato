import json
import ../../../../../src/basolato/view

let style = block:
  var css = newCss()
  css.set("form", "", """
    padding: 10px 0px;
  """)
  css

proc inputView*(params=newJObject(), errors=newJObject()):string = tmpli html"""
$(style.define())
<div class="container">
  <form method="POST" class="field $(style.get("form"))">
    $(csrfToken())
    <div class="field">
      <div class="controll">
        <input type="text" name="title" placeholder="title" class="input" value="$(old(params, "title"))">
      </div>
    </div>

    <div class="field">
      <div class="controll">
        <textarea name="content" placeholder="content" class="textarea">$(old(params, "content"))</textarea>
      </div>
    </div>

    <div class="field">
      <div class="controll">
        <button type="submit" class="button is-primary is-light is-outlined">add</button>
      </div>
    </div>
  </form>
</div>
"""
