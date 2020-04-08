import basolato/view

proc headerHtml*():string = tmpli html"""
<header class="navbar navbar-fixed-top navbar-inverse">
  <div class="container">
    <a href="/" id="logo">sample app</a>
    <nav>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="/">Home</a></li>
        <li><a href="/help">Help</a></li>
        <li><a href="/login">Log In</a></li>
      </ul>
    </nav>
  </div>
</header>
"""
