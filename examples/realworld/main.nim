# framework
import basolato
import ./app/env
# middleware
import ./app/http/middlewares/session_middleware
import ./app/http/middlewares/auth_middleware
import ./app/http/middlewares/set_headers_middleware
# controller
import ./app/http/controllers/welcome_controller
import ./app/http/controllers/auth_controller
import ./app/http/controllers/setting_controller
import ./app/http/controllers/home_controller
import ./app/http/controllers/article_controller
import ./app/http/controllers/profile_controller


let routes = @[
  Route.group("", @[
    Route.group("", @[
      Route.get("/login", auth_controller.signInPage).middleware(auth_middleware.loginSkip),
      Route.post("/login", auth_controller.signIn),
      Route.get("/register", auth_controller.signUpPage).middleware(auth_middleware.loginSkip),
      Route.post("/register", auth_controller.signUp),
      Route.post("/logout", auth_controller.signOut),
      Route.get("/settings", setting_controller.settingPage),
      Route.post("/settings", setting_controller.updateSettings),

      Route.get("/", home_controller.homePage),
      Route.get("/your-feed", home_controller.homePage),
      Route.get("/tag/{tag:str}", home_controller.homePage),

      Route.get("/article/{articleId:str}", article_controller.show),

      Route.get("/profile/{userId:str}", profile_controller.show),
      Route.get("/profile/{userId:str}/favorite", profile_controller.favoriteShow),
      Route.post("/profile/{userId:str}/follow", profile_controller.follow).middleware(auth_middleware.loginRequired),
    ])
    .middleware(session_middleware.sessionFromCookie)
    .middleware(session_middleware.checkCsrfToken),

    Route.group("/api", @[
      Route.get("/index", welcome_controller.indexApi),
    ])
    .middleware(set_headers_middleware.setSecureHeaders)
  ])
  .middleware(set_headers_middleware.setCorsHeaders)
]

let settings = 
  when not defined(release):
    Settings.new(
      host = "0.0.0.0",
      sessionTime = 0,
    )
  else:
    Settings.new(
      host = "0.0.0.0",
    )

serve(routes, settings)
