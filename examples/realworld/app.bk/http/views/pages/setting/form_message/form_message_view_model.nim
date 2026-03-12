import ../../../islands/form_success_message/form_success_message_view_model


type FormMessageViewModel*  = object
  oobSwap*:bool
  formSuccessMessageViewModel*:FormSuccessMessageViewModel

proc new*(_:type FormMessageViewModel, oobSwap:bool, message:string): FormMessageViewModel =
  let formSuccessMessageViewModel = FormSuccessMessageViewModel.new(message)
  let viewModel = FormMessageViewModel(
    oobSwap: oobSwap,
    formSuccessMessageViewModel: formSuccessMessageViewModel
  )
  return viewModel
