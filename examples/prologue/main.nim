import
  prologue,
  prologue/middlewares/memorysession,
  prologue/middlewares/auth,
  ./controller


let settings = newSettings(port=Port(5000))
var app = newApp(settings=settings)
echo sessionMiddleware(settings).repr
app.use(sessionMiddleware(settings))
app.get("/", index)
app.get("/{id}", show)
app.run()
