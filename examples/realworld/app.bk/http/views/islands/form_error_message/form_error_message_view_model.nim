type FormErrorMessageViewModel*  = object
  errors*:seq[string]


proc new*(_:type FormErrorMessageViewModel, errors:seq[string]): FormErrorMessageViewModel =
  return FormErrorMessageViewModel(
    errors: errors
  )
