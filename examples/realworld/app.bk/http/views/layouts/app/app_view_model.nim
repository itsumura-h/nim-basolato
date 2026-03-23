import ../navbar/navbar_view_model


type AppViewModel*  = object
  title*:string
  navbarViewModel*:NavbarViewModel

proc new*(_:type AppViewModel, title:string, navbarViewModel:NavbarViewModel):AppViewModel =
  return AppViewModel(
    title:title,
    navbarViewModel:navbarViewModel
  )
