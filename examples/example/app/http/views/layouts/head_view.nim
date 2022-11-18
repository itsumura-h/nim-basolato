import ../../../../../../src/basolato/view


proc headView*(title:string):Component =
  tmpli html"""
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <title>$(title)</title>
      <!-- <script src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js" defer></script> -->
      <!-- <link rel="stylesheet" href="https://unpkg.com/mvp.css"> -->
    </head>
  """
