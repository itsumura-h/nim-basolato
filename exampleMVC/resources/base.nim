# import ../../src/basolato/view
import ../../src/basolato/private
import ../../src/basolato/session


proc header(): string = """
<title>Basolato Webpage sample blog</title>
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
<link href="//fonts.googleapis.com/css?family=Lobster&subset=latin,latin-ext" rel="stylesheet" type="text/css">
<link rel="stylesheet" href="/css/blog.css">
"""

proc baseHtml*(login:Login, content:string): string =
  tmpli html"""
<html>
  <head>
    $(header())
  </head>
  <body>
    <div class="page-header">
      $if login.isLogin {
        <p class="top-menu">Login: $(login.info["login_name"])</p>
        <a href="/logout" class="top-menu"><span class="glyphicon glyphicon-log-out"></span></a>
        <a href="/posts/create" class="top-menu"><span class="glyphicon glyphicon-plus"></span></a>
      }
      $else {
        <a href="/signUp" class="top-menu"><span class="glyphicon glyphicon-user"></span></a>
        <a href="/login" class="top-menu"><span class="glyphicon glyphicon-log-in"></span></a>
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
