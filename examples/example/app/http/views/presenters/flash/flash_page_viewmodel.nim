import std/json
import ../../../../../../../src/basolato/view


type FlashPageViewModel* = object
  flashMessages*: JsonNode
  csrfToken*: string


proc new*(_: type FlashPageViewModel, flashMessages: JsonNode, csrfToken: string): FlashPageViewModel =
  return FlashPageViewModel(
    flashMessages: flashMessages,
    csrfToken: csrfToken
  )
