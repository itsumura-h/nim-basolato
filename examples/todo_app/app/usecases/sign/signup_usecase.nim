import ../../../di_container


type SignupUsecase* = ref object

func new*(typ:type SignupUsecase):SignupUsecase =
  typ()
