when defined(httpbeast):
  import ./beta/view
else:
  import ./std/view

export view
