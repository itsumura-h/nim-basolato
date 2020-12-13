import ../../../../src/basolato/view

proc headView*(title:string):string = tmpli html"""
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta charset="UTF-8">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.1/css/bulma.min.css">
  <title>$title</title>
</head>
"""
