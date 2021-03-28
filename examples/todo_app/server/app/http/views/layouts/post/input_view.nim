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

proc inputView*(params:Params):string = tmpli html"""
$(style)
<div class="container">
  <form method="POST" class="field $(style.get("form"))">
    $(csrfToken())
    <div class="field">
      <div class="controll">
        <input type="text" name="title" placeholder="title" class="input" value="$(old(params, "title"))">
      </div>
      $if params.hasError("title"){
        <ul class="$(style.get("errors"))">
          $for error in params.errors["title"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
    </div>

    <div class="field">
      <div class="controll">
        <textarea name="content" placeholder="content" class="textarea">$(old(params, "content"))</textarea>
      </div>
      $if params.hasError("content"){
        <ul class="$(style.get("errors"))">
          $for error in params.errors["content"]{
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
