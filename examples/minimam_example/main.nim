import ../../src/basolato
import ../../src/basolato/settings
import ./app/controllers/example_controller
import std/asyncdispatch


let routes = @[
  Route.get("/", example_controller.index),
  Route.get("/{id:int}", example_controller.show),
]


let setting = Settings.new(
  host="0.0.0.0",
)
echo setting

echo "SECRET_KEY: ", SECRET_KEY
echo "LOG_TO_CONSOLE: ",LOG_TO_CONSOLE
echo "LOG_TO_FILE: ",LOG_TO_FILE
echo "ERROR_LOG_TO_FILE: ",ERROR_LOG_TO_FILE
echo "LOG_DIR: ",LOG_DIR
echo "SESSION_TIME: ",SESSION_TIME
echo "SESSION_EXPIRE_ON_CLOSE: ",SESSION_EXPIRE_ON_CLOSE
echo "LOCALE: ",LOCALE

serve(routes, setting)
