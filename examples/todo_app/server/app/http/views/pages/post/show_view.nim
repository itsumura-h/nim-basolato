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
    <form method="POST" action="/$(post["id"].get)" class="field $(style.get("form"))">
      $(csrfToken())
      <div class="field">
        <div class="controll">
          $if params.len > 0{
            <input type="text" name="title" placeholder="title" class="input" value="$(params["title"].get)">
          }
          $else{
            <input type="text" name="title" placeholder="title" class="input" value="$(post["title"].get)">
          }
        </div>
        $if errors.hasKey("title"){
          <div class="controll">
            <ul class="$(style.get("error"))">
              $for error in errors["title"]{
                <li>$(error.get)</li>
              }
            </ul>
          </div>
        }
      </div>
  
      <div class="field">
        <div class="controll">
          $if params.len > 0{
            <textarea name="content" placeholder="content" class="textarea">$(params["content"].get)</textarea>
          }
          $else{
            <textarea name="content" placeholder="content" class="textarea">$(post["content"].get)</textarea>
          }
        </div>
        $if errors.hasKey("content"){
          <div class="controll">
            <ul class="$(style.get("error"))">
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
            $if params.len > 0{
              <option value="true" $if params["is_finished"].getBool{selected}>Finished</option>
              <option value="false" $if not params["is_finished"].getBool{selected}>Not finished</option>
            }
            $else{
              <option value="true" $if post["is_finished"].getBool{selected}>Finished</option>
              <option value="false" $if not post["is_finished"].getBool{selected}>Not finished</option>
            }
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
