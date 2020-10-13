import prologue
import controller

var settings = newSettings()
settings.port = 5000.Port()
var app = newApp(settings = settings)
app.addRoute("/", controller.hello)
app.addRoute("/db", controller.db)
app.run()