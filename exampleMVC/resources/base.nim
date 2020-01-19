import ../../src/basolato/view


proc header(): string = """
<title>Basolato Webpage sample blog</title>
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
<link href="//fonts.googleapis.com/css?family=Lobster&subset=latin,latin-ext" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="/css/blog.css">
"""

proc baseHtml*(content:string, loginUser=""): string = tmpli html"""
<html>
  <head>
    $(header())
  </head>
  <body>
    <div class="page-header">
      $if loginUser.len > 0 {
        <p class="top-menu">Login: $loginUser</p>
        <a href="/posts/create" class="top-menu"><span class="glyphicon glyphicon-plus"></span></a>
      }
      $else {
        <a href="/signUp" class="top-menu"><span class="glyphicon glyphicon-user"></span></a>
      }
      <h1><a href="/posts">Basolato sample blog</a></h1>
    </div>
    <div class="content container">
      <div class="row">
        <div class="col-md-8">
          $(content)
        </div>
      </div>
    </div>
  </body>
</html>
"""
