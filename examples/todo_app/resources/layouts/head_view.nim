import ../../../../src/basolato/view

proc headView*(title:string):string = tmpli html"""
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://fonts.xz.style/serve/inter.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@exampledev/new.css@1.1.2/new.min.css">
  <link rel="stylesheet" href="/css/style.css">
  <title>$title</title>
</head>
"""
