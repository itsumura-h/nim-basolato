import faker

let fake = newFaker()

proc randomText*(num:int):string =
  for i in 0..<num:
    if i > 0: result.add(" ")
    result.add(
      fake.word()
    )
