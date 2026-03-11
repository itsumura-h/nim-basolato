import std/json
import ../../../../../../../src/basolato/view


type ValidationPageViewModel* = object
  formParams*: Params
  formErrors*: JsonNode


proc new*(_: type ValidationPageViewModel, formParams: Params, formErrors: JsonNode): ValidationPageViewModel =
  return ValidationPageViewModel(
    formParams: formParams,
    formErrors: formErrors
  )
