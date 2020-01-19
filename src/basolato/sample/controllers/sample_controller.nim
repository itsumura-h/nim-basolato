import basolato/controller
# view
import ../resources/welcome

type SampleController* = ref object
  request: Request

proc newSampleController*(request:Request): SampleController =
  return SampleController(
    request:request
  )

proc index*(this:SampleController):Response =
  let name = "Basolato " & basolatoVersion
  return render(welcomeHtml(name))
