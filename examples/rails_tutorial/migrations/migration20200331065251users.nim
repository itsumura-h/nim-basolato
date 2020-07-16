import allographer/schema_builder
import allographer/query_builder
import ../domain/usecases/users_usecase

proc migration20200331065251users*() =
  schema([
    table("users", [
      Column().increments("id"),
      Column().string("name"),
      Column().string("email").unique(),
      Column().string("password"),
      Column().timestamps()
    ], reset=true)
  ])

  discard newUsersUsecase().store(
    name="Michael Hartl",
    email="example@railstutorial.org",
    password="foobar"
  )
