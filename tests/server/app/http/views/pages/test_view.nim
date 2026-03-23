import ../../../../../../src/basolato/view

proc testView*(context: Context):Component =
  tmpl"""
    <h1>test template</h1>
    $(context.csrfToken())
  """
