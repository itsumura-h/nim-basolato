import basolato/view

type EditorTemplateModel* = object
  csrfToken*: CsrfToken
  action*: string
  title*: string
  description*: string
  body*: string
  tags*: string

proc new*(_: type EditorTemplateModel,
  context: Context,
  action: string,
  title = "",
  description = "",
  body = "",
  tags = "",
): EditorTemplateModel =
  return EditorTemplateModel(
    csrfToken: context.csrfToken(),
    action: action,
    title: title,
    description: description,
    body: body,
    tags: tags,
  )
