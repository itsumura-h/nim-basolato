import json
import ../../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/post/errors_view

style "css", style:"""
.form{
  padding: 10px 0px;
}

.error{
  background-color: pink;
  color: red;
}
"""

proc impl(params, errors, post:JsonNode):Future[string] {.async.} = tmpli html"""
$(style)
<section class="section">
  <div class="container is-max-desktop">
    <a href="/">back</a>
    <form method="POST" action="/$(post["id"].get)" class="field $(style.element("form"))">
      $(csrfToken())
      <div class="field">
        <input type="text" name="title" placeholder="title" class="input" value="$(old(params, "title", post["title"].get))">
        $if errors.hasKey("title"){
          <div class="controll">
            <ul class="$(style.element("error"))">
              $for error in errors["title"]{
                <li>$(error.get)</li>
              }
            </ul>
          </div>
        }
      </div>

      <div class="field">
        <div class="controll">
          <textarea name="content" placeholder="content" class="textarea">$(old(params, "content", post["content"].get))</textarea>
        </div>
        $if errors.hasKey("content"){
          <div class="controll">
            <ul class="$(style.element("error"))">
              $for error in errors["content"]{
                <li>$(error.get)</li>
              }
            </ul>
          </div>
        }
      </div>

      <div class="field">
        <div class="select">
          <select name="is_finished">
            <option
              value="true"
              $if old(params, "is_finished", post["is_finished"].get) == "true"{
                selected
              }
            >
              Finished
            </option>
            <option
              value="false"
              $if old(params, "is_finished", post["is_finished"].get) != "true"{
                selected
              }
            >
              Not finished
            </option>
          </select>
        </div>
      </div>
      $(errorsView(errors))
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

proc showView*(client:Client, post=newJObject()):Future[string] {.async.} =
  let title = ""
  let (params, errors) = await client.getValidationResult()
  return applicationView(title, await impl(params, errors, post))
