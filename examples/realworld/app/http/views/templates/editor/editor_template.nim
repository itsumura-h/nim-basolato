import basolato/view
import ./editor_template_model

proc editorTemplate*(model: EditorTemplateModel): Component =
  tmpl"""
    <div class="editor-page">
      <div class="container page">
        <div class="row">
          <div class="col-md-10 offset-md-1 col-xs-12">
            <form action="$(model.action)" method="post">
              $(model.csrfToken)
              <fieldset>
                <fieldset class="form-group">
                  <input class="form-control form-control-lg" type="text" name="title" value="$(model.title)" placeholder="Article Title" />
                </fieldset>
                <fieldset class="form-group">
                  <input class="form-control" type="text" name="description" value="$(model.description)" placeholder="What's this article about?" />
                </fieldset>
                <fieldset class="form-group">
                  <textarea class="form-control" name="body" rows="8" placeholder="Write your article (in markdown)">$(model.body)</textarea>
                </fieldset>
                <fieldset class="form-group">
                  <input class="form-control" type="text" name="tags" value="$(model.tags)" placeholder="Enter tags" />
                </fieldset>
                <button class="btn btn-lg pull-xs-right btn-primary" type="submit">
                  Save Article
                </button>
              </fieldset>
            </form>
          </div>
        </div>
      </div>
    </div>
  """
