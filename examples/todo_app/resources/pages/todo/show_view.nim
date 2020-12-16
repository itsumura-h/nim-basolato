import json
import ../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/todo/errors_view

let style = block:
  var css = newCss()
  css.set("form", "", """
    padding: 10px 0px;
  """)
  css

proc impl(auth:Auth, post:JsonNode):string = tmpli html"""
$(style.define())
<section class="section">
  <div class="container is-max-desktop">
    <a href="/">back</a>
    <form method="POST" action="/$(post["id"].get)" class="field $(style.get("form"))">
      $(csrfToken())
      <div class="field">
        <div class="controll">
          <input type="text" name="title" placeholder="title" class="input" value="$(post["title"].get)">
        </div>
      </div>
  
      <div class="field">
        <div class="controll">
          <textarea name="content" placeholder="content" class="textarea">$(post["content"].get)</textarea>
        </div>
      </div>
  
      <div class="field">
        <div class="select">
          <select name="is_finished">
            $if post["is_finished"].getBool == true{
              <option value="true" selected>Finished</option>
              <option value="false">Not finished</option>
            }
            $else{
              <option value="true">Finished</option>
              <option value="false" selected>Not finished</option>
            }
          </select>
        </div>
      </div>
  
      $(errorsView(auth))
  
      <div class="field">
        <div class="controll">
          <button type="submit" class="button is-primary is-light is-outlined">update</button>
        </div>
      </div>
    </form>
  
    <form method="POST" action="/delete/$(post["id"].get)">
      $(csrfToken())
      <div class="field">
        <div class="controll">
          <button type="submit" class="button is-danger is-light is-outlined">delete</button>
        </div>
      </div>
    </form>
  
  </div>
</section>
"""

proc showView*(auth:Auth, post=newJObject()):string =
  let title = ""
  return applicationView(title, impl(auth, post))
