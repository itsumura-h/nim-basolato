import templates

proc welcomeHtml*(name:string): string = tmpli html"""

<head>
  <link rel="stylesheet" href="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/dracula.min.css">
  <script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
  <style>
    #title {
      color: goldenrod;
      text-align: center;
    }

    #topImage {
      background-color: gray;
      text-align: center;
    }

    .goldFont {
      color: goldenrod
    }

    .whiteFont {
      color: white
    }

    .ulLink li {
      margin: 8px;
    }

    .ulLink li a {
      color: skyblue;
    }

    .architecture {
      padding: 10px
    }

    .architecture h2 {
      color: goldenrod
    }

    .components {
      display:flex
    }

    .discription {
      width: 50vw
    }

    .discription h3 {
      color: goldenrod
    }

    .discription p {
      color: white
    }

    .sourceCode {
      width: 50vw
    }

    .sourceCode p {
      color: white;
      margin-bottom: 0;
    }

    .sourceCode pre {
      margin-top: 0;
    }
  </style>
</head>

<body style="background-color: black">
  <h1 id="title">Nim $(name) is successfully running!!!</h1>
  <div id="topImage">
    <image src="https://raw.githubusercontent.com/nim-lang/assets/master/Art/logo-crown.png" style="height: 40vh" />
  </div>
  <h2 class="goldFont">
    Fullstack Web Framewrok for Nim
  </h2>
  <p class="whiteFont">
    <i>—utilitas, firmitas and venustas (utility, strength and beauty)—</i> by De architectura / Marcus Vitruvius Pollio
  </p>
  <p class="whiteFont">
    Basolate is compatible multiple Architecture
    <ul class="ulLink">
      <li><a href="#MVC_Architecture">MVC Architecture</a></li>
      <!--
      <li><a href="#DDD">Domain-Driven Design</a></li>
      <li><a href="#clean">Clean Architecture</a></li>
      -->
    </ul>
  </p>

  <!-- architecture -->
  <div class="architecture">
    <h2 id="MVC_Architecture">MVC Architecture</h2>
    <!-- Routing -->
    <div class="components">
      <div class="discription">
        <h3>Routing</h3>
        <p>
          Routing is written in main.nim. it is the entrypoint file of Basolato.
          Routing of Basolato is exactory the same as Jester, although you can call controller method by route()
        </p>
      </div>
      <div class="sourceCode">
        <p>main.nim</p>
        <pre>
        <code class="nimrod">
import basolato/routing
 
import app/controllers/posts_controllers
 
routes:
  error Http404:
    http404Route
 
  error Exception:
    exceptionRoute
 
  get "/posts":
    route(newPostsController().index())
  get "/posts/@id":
    route(newPostsController().show(@"id"))
  get "/posts/create":
    route(newPostsController().create())
  post "/posts/create":
    route(newPostsController().store(request))
        </code>
      </pre>
      </div>
    </div>

    <!-- Controller -->
    <div class="components">
      <div class="discription">
        <h3>Controller</h2>
        <p>
          Resource controllers are controllers that have basic CRUD / resource style methods to them.
          Generated controller is resource controller.
        </p>
      </div>
      <div class="sourceCode">
        <p>app/controllers/posts_controllers.nim</p>
        <pre>
        <code class="nimrod">
import basolato/controller
 
import ../models/users
import ../models/auth
 
import ../../resources/users/index
import ../../resources/users/show
import ../../resources/users/edit
 
type UsersController = ref object of Controller
  # DI
  user: User
  auth: Auth
 
proc newUsersController*(): UsersController =
  # constructor
  return UsersController(
    user: newUser(),
    auth: newAuth()
  )
 
  
proc index*(this:UsersController): Response =
  let users = this.user.getUsers()
  return render(indexHtml(users))
 
proc show*(this:UsersController, idArg:string): Response =
  let id = idArg.parseInt
  let user = this.user.getUser(id)
  return render(showHtml(user))
 
proc edit*(this:UsersController, idArg:string): Response =
  let id = idArg.parseInt
  let user = this.user.getUser(id)
  let auth = this.auth.getAuth()
  return render(editHtml(user, auth))
        </code>
      </pre>
      </div>
    </div>
  </div>

<!--
  <div class="architecture" style="background-color: #101010">
    <h2 id="DDD">Domain-Driven Design(DDD)</h2>
    <div class="components">
      <div class="discription">
        <h3>discription</h3>
        <p>discription</p>
      </div>
      <div class="sourceCode">
        <p>source code</p>
        <pre>
          <code class="nimrod">
            aaaa
          </code>
        </pre>
      </div>
    </div>
  </div>
-->
<!--
  <div class="architecture">
    <h2 id="clean">Clean Architecture</h2>
    <div class="components">
      <div class="discription">
        <h3>discription</h3>
        <p>discription</p>
      </div>
      <div class="sourceCode">
        <p>source code</p>
        <pre>
          <code class="nimrod">
            aaaa
          </code>
        </pre>
      </div>
    </div>
  </div>
-->
  <script>hljs.initHighlightingOnLoad();</script>
</body>
"""

#[
  <div class="architecture">
    <h2>architecture title</h2>
    <div class="components">
      <div class="discription">
        <h3>discription</h3>
        <p>discription</p>
      </div>
      <div class="sourceCode">
        <p>source code</p>
        <pre>
          <code class="nimrod">
            aaaa
          </code>
        </pre>
      </div>
    </div>
  </div>
]#