import basolato/routing

import config/customHeaders
import basolato/sample/controllers/SampleController

routes:
  get "/":
    route(SampleController.index())

runForever()
