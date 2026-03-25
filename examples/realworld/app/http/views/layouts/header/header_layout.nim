import basolato/view
import ./header_layout_model

proc headerLayout*(layoutModel: HeaderLayoutModel): Component =
  tmpl"""
    <nav class="navbar navbar-light">
      <div class="container">
        <a class="navbar-brand" href="/">conduit</a>
        <ul class="nav navbar-nav pull-xs-right">
          <li class="nav-item">
            <!-- Add "active" class when you're on that page" -->
            <a class="nav-link $if layoutModel.pageUrl == "/"{active}" href="/">Home</a>
          </li>
          $if not layoutModel.isLogin{
            <li class="nav-item">
              <a class="nav-link" href="/login">Sign in</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="/register">Sign up</a>
            </li>
          }
        </ul>
      </div>
    </nav>
  """
