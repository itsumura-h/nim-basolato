const
  basolatoVersion* = "0.6.0"

type
  Error505* = object of CatchableError
  Error504* = object of CatchableError
  Error503* = object of CatchableError
  Error502* = object of CatchableError
  Error501* = object of CatchableError
  Error500* = object of CatchableError
  Error451* = object of CatchableError
  Error431* = object of CatchableError
  Error429* = object of CatchableError
  Error428* = object of CatchableError
  Error426* = object of CatchableError
  Error422* = object of CatchableError
  Error421* = object of CatchableError
  Error418* = object of CatchableError
  Error417* = object of CatchableError
  Error416* = object of CatchableError
  Error415* = object of CatchableError
  Error414* = object of CatchableError
  Error413* = object of CatchableError
  Error412* = object of CatchableError
  Error411* = object of CatchableError
  Error410* = object of CatchableError
  Error409* = object of CatchableError
  Error408* = object of CatchableError
  Error407* = object of CatchableError
  Error406* = object of CatchableError
  Error405* = object of CatchableError
  Error404* = object of CatchableError
  Error403* = object of CatchableError
  Error401* = object of CatchableError
  Error400* = object of CatchableError
  Error307* = object of CatchableError
  Error305* = object of CatchableError
  Error304* = object of CatchableError
  Error303* = object of CatchableError
  Error302* = object of CatchableError
  Error301* = object of CatchableError
  Error300* = object of CatchableError
  ErrorAuthRedirect* = object of CatchableError
  DD* = object of CatchableError

const errorStatusArray* = [505, 504, 503, 502, 501, 500, 451, 431, 429, 428, 426,
  422, 421, 418, 417, 416, 415, 414, 413, 412, 411, 410, 409, 408, 407, 406,
  405, 404, 403, 401, 400, 307, 305, 304, 303, 302, 301, 300]

proc dd*(outputs: varargs[string]) =
  when not defined(release):
    var output:string
    for i, row in outputs:
      if i > 0: output &= "\n\n" else: output &= "\n"
      output.add(row)
    raise newException(DD, output)
