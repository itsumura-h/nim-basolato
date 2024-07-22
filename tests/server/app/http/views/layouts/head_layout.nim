import ../../../../../../src/basolato/view

proc headView*():Component =
  tmpl"""
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
  """
