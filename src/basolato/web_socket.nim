when defined(httpbeast):
  import ./beta/web_socket
elif defined(httpx):
  import ./beta/web_socket
else:
  import ./std/web_socket

export web_socket
