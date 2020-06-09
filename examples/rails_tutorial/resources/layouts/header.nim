import ../../../../src/basolato/view

proc headerHtml*(auth:Auth):string = tmpli html"""
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <a href="/" id="logo">sample app</a>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="/">Home</a></li>
        <li><a href="/help">Help</a></li>
        $if auth.isLogin(){
          <li><a href="#">Users</a></li>
          <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              Account <b class="caret"></b>
            </a>
            <ul class="dropdown-menu">
              <li><a href="/users/$(auth.get("id"))">Profile</a></li>
              <li><a href="#">Settings</a></li>
              <li class="divider"></li>
              <form method="POST" action="/logout" name="logout_form">
                $(csrfToken())
              </form>
              <li><a href="javascript:logout_form.submit()">log out</a></li>
            </ul>
          </li>
        }
        $else{
          <li><a href="/login">Log In</a></li>
        }
      </ul>
    </nav>
  </div>
</header>
"""
