import std/json
import ../../../../../../../src/basolato/view


type ValidationPageViewModel* = object
  formParams*: Params
  formErrors*: JsonNode
  csrfToken*: string


proc new*(_: type ValidationPageViewModel, formParams: Params, formErrors: JsonNode, csrfToken: string): ValidationPageViewModel =
  return ValidationPageViewModel(
    formParams: formParams,
    formErrors: formErrors,
    csrfToken: csrfToken
  )
