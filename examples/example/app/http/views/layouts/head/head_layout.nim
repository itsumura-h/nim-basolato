import ../../../../../../../src/basolato/view
import ./head_layout_model


proc headLayout*(model:HeadLayoutModel):Component =
  tmpl"""
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <title>$(model.title)</title>
      <script type="module" src="https://unpkg.com/@hotwired/turbo@8.0.5/dist/turbo.es2017-esm.js"></script>
      <link rel="stylesheet" href="https://unpkg.com/mvp.css">
      <script type="module" src="https://unpkg.com/@hotwired/turbo@8.0.5/dist/turbo.es2017-esm.js"></script>
      $if model.reload{
        <meta name="turbo-visit-control" content="reload">
      }
    </head>
  """
