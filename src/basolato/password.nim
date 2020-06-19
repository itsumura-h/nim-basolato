import bcrypt

proc genHashedPassword*(val:string):string =
  let salt = genSalt(10)
  return val.hash(salt)

proc isMatchPassword*(input, hashedPassword:string):bool =
  let salt = hashedPassword[0..28]
  let hashedInput = input.hash(salt)
  return compare(hashedInput, hashedPassword)
