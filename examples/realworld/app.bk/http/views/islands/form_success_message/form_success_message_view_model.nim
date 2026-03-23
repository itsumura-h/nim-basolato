type FormSuccessMessageViewModel*  = object
  message*:string

proc new*(_:type FormSuccessMessageViewModel, message:string): FormSuccessMessageViewModel =
  return FormSuccessMessageViewModel(message: message)
