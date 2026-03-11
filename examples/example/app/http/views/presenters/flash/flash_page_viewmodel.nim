import std/json
import ../../../../../../../src/basolato/view


type FlashPageViewModel* = object
  flashMessages*: JsonNode


proc new*(_: type FlashPageViewModel, flashMessages: JsonNode): FlashPageViewModel =
  return FlashPageViewModel(
    flashMessages: flashMessages
  )
