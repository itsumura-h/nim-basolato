import std/json
import ../../../../../../../src/basolato/view


type CookiePageViewModel* = object
  cookies*: JsonNode
  csrfToken*: string


proc new*(_: type CookiePageViewModel, cookies: JsonNode, csrfToken: string): CookiePageViewModel =
  return CookiePageViewModel(
    cookies: cookies,
    csrfToken: csrfToken
  )
