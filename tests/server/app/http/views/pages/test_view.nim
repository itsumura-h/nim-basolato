import ../../../../../../src/basolato/view

proc testView*():Component =
  tmpl"""
    <h1>test template</h1>
    $(csrfToken())
  """
