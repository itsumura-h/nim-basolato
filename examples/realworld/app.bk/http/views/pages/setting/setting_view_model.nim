import ../../../../models/dto/user/user_dto
import ./form_message/form_message_view_model
import ./form/form_view_model


type SettingViewModel*  = object
  fromMessageViewModel*:FormMessageViewModel
  formViewModel*:FormViewModel

proc new*(_:type SettingViewModel,
  loginUserDto:UserDto,
):SettingViewModel =
  let fromMessageViewModel = FormMessageViewModel.new(
    false,
    "",
  )
  let formViewModel = FormViewModel.new(
    false,
    loginUserDto.name,
    loginUserDto.email,
    loginUserDto.bio,
    loginUserDto.image,
  )

  let viewModel = SettingViewModel(
    fromMessageViewModel: fromMessageViewModel,
    formViewModel: formViewModel,
  )
  return viewModel


proc new*(_:type SettingViewModel,
  loginUserDto:UserDto,
  successMessage:string,
):SettingViewModel =
  let fromMessageViewModel = FormMessageViewModel.new(
    true,
    successMessage,
  )
  let formViewModel = FormViewModel.new(
    true,
    loginUserDto.name,
    loginUserDto.email,
    loginUserDto.bio,
    loginUserDto.image,
  )

  let viewModel = SettingViewModel(
    fromMessageViewModel: fromMessageViewModel,
    formViewModel: formViewModel,
  )
  return viewModel
