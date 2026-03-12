import std/options
import basolato/view
import ../../layouts/app/app_view_model
import ../../layouts/app/app_view
import ./editor_view_model


proc impl(viewModel:EditorViewModel):Component =
  tmpl"""
    <div class="editor-page">
      <div class="container page">
        <div class="row">

          <div class="col-md-10 col-md-offset-1 col-xs-12">

            <div id="form-message"></div>

            <form method="post"

              $if viewModel.article.isSome(){
                ${ let article = viewModel.article.get() }
                hx-post="/islandndnd/editor/$( article.id )"
              }$else{
                hx-post="/island/editor"
              }

              hx-target="#app-body"
            >
              $(csrfToken())
              <fieldset class="form-group">
                <input type="text" name="title" class="form-control form-control-lg" placeholder="Post Title"
                  $if viewModel.article.isSome(){
                    value="$( viewModel.article.get().title )"
                  }
                >
              </fieldset>
              <fieldset class="form-group">
                <input type="text" name="description" class="form-control form-control-md" placeholder="What's this article about?"
                  $if viewModel.article.isSome(){
                    value="$( viewModel.article.get().description )"
                  }
                >
              </fieldset>
              <fieldset class="form-group">
                <textarea rows="8" name="body" class="form-control" placeholder="Write your post (in markdown)">$if viewModel.article.isSome(){$(viewModel.article.get().body)}</textarea>
              </fieldset>
              <fieldset class="form-group">
                <input type="text" name="tags" class="form-control tagify--outside" placeholder="Enter tags"
                  $if viewModel.article.isSome(){
                    value="$( viewModel.article.get().tags )"
                  }
                >
              </fieldset>
              <button class="btn btn-lg btn-primary pull-xs-right">
                Publish Article
              </button>
            </form>
          </div>
        </div>
      </div>
    </div>
  """

proc editorView*(appViewModel:AppViewModel, viewModel:EditorViewModel):Component =
  appView(appViewModel, impl(viewModel))

proc islandEditorView*(viewModel:EditorViewModel):Component =
  impl(viewModel)
