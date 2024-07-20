import ../../../../../../../src/basolato/view
import ./head_template_model


proc headTemplate*(viewModel:HeadTemplateModel):Component =
  tmpl"""
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <title>$(viewModel.title)</title>
      <link rel="stylesheet" href="https://unpkg.com/mvp.css">
    </head>
  """
