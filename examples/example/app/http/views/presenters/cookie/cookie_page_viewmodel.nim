import std/json
import ../../../../../../../src/basolato/view


type CookiePageViewModel* = object
  cookies*: JsonNode


proc new*(_: type CookiePageViewModel, cookies: JsonNode): CookiePageViewModel =
  return CookiePageViewModel(
    cookies: cookies
  )
