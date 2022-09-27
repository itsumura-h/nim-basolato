when defined(httpbeast):
  import ./beta/password
else:
  import ./std/password

export password
