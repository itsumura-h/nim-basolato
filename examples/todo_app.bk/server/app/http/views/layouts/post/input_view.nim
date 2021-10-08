import json
import ../../../../../../../../src/basolato/view

style "css", style:
  """
.form{
  padding: 10px 0px;
}

.errors{
  background-color: pink;
  color: red;
}
"""

proc inputView*(params, errors:JsonNode):string = tmpli html"""
$(style)
<div class="container">
  <form method="POST" class="field $(style.element("form"))">
    $(csrfToken())
    <div class="field">
      <div class="controll">
        <input type="text" name="title" placeholder="title" class="input" value="$(old(params, "title"))">
      </div>
      $if errors.hasKey("title"){
        <ul class="$(style.element("errors"))">
          $for error in errors["title"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
    </div>

    <div class="field">
      <div class="controll">
        <textarea name="content" placeholder="content" class="textarea">$(old(params, "content"))</textarea>
      </div>
      $if errors.hasKey("content"){
        <ul class="$(style.element("errors"))">
          $for error in errors["content"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
    </div>

    <div class="field">
      <div class="controll">
        <button type="submit" class="button is-primary is-light is-outlined">add</button>
      </div>
    </div>
  </form>
</div>
"""
