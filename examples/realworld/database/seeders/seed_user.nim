import std/asyncdispatch
import std/json
import std/times
import std/strutils
import std/strformat
import std/random
import basolato/password
import allographer/query_builder
import faker
import ./lib/random_text
import ../../app/models/vo/user_id
import ../schema


type User = object
  id: UserTable.id
  name: UserTable.name
  email: UserTable.email
  password: UserTable.password
  bio: UserTable.bio
  image: UserTable.image
  created_at: UserTable.created_at


proc generateRandomRGB(): string =
  let r = rand(255).toHex()[^2..^1]
  let g = rand(255).toHex()[^2..^1]
  let b = rand(255).toHex()[^2..^1]
  return r & g & b


proc user*(rdb: PostgresConnections) {.async.} =
  let fake = newFaker()

  var users: seq[User]
  for i in 1..20:
    let id = UserId.new()
    let name = fake.name()
    let imageName = name.toLowerAscii().multiReplace([(".", ""), (" ", "+")])
    let rpg = generateRandomRGB()
    let user = User(
      id: id.value,
      name: name,
      email: fake.email(),
      password: genHashedPassword("password"),
      bio: randomText(30),
      image: &"https://via.placeholder.com/640x480.png/{rpg}?text={imageName}",
      createdAt: now().utc().format("yyyy-MM-dd hh:mm:ss")
    )
    users.add(user)

  users.add(
    User(
      id: UserId.new().value,
      name: "admin",
      email: "admin@example.com",
      password: genHashedPassword("password"),
      bio: "admin",
      image: "https://via.placeholder.com/640x480.png/000000?text=admin",
      createdAt: now().utc().format("yyyy-MM-dd hh:mm:ss")
    )
  )

  rdb.table("user").insert(users).await
