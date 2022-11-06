import basolato/view


proc headView*(title:string):Component =
  tmpli html"""
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.0/css/all.min.css" rel="stylesheet">
      <title>$(title)</title>
    </head>
  """
