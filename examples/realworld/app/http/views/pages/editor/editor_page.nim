import std/asyncdispatch
import basolato/view
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model
import ../../templates/editor/editor_template
import ../../templates/editor/editor_template_model

proc editorPageView*(context: Context, action: string, title = "", description = "", body = "", tags = ""): Future[Component] {.async.} =
  let model = EditorTemplateModel.new(context, action, title, description, body, tags)
  let bodyComponent = editorTemplate(model)
  let appLayoutModel = AppLayoutModel.new(context, "Editor", bodyComponent).await
  return appLayout(appLayoutModel)
