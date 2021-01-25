import interface_class
import impl_class

proc application(animalInterface:IAnimal) = # 抽象に依存
  echo  animalInterface.walk() # ポリモーフィズム

proc presentation() =
  let cat = newCat().toInterface()
  application(cat) # 依存性の注入

presentation()
