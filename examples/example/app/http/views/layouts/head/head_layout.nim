import ../../../../../../../src/basolato/view
import ./head_layout_model


proc headLayout*(model:HeadLayoutModel):Component =
  tmpl"""
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <title>$(model.title)</title>
      <link rel="stylesheet" href="https://unpkg.com/mvp.css">
    </head>
  """
