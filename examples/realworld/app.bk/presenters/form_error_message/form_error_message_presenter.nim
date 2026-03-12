import std/json
import ../../http/views/islands/form_error_message/form_error_message_view_model


type FormErrorMessagePresenter* = object

proc new*(_:type FormErrorMessagePresenter):FormErrorMessagePresenter =
  return FormErrorMessagePresenter()


proc invoke*(self:FormErrorMessagePresenter, errors:JsonNode):FormErrorMessageViewModel =
  var errorMessages:seq[string]
  for (key, rows) in errors.pairs:
    for row in rows.items:
      errorMessages.add(row.getStr())
  let viewModel = FormErrorMessageViewModel.new(errorMessages)
  return viewModel
