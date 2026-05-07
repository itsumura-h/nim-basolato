import rustcrypto/algorithm/bcrypt


proc genHashedPassword*(val:string):string =
  return Bcrypt.hashPassword(val)

proc isMatchPassword*(input, hashedPassword:string):bool =
  try:
    return Bcrypt.verifyPassword(input, hashedPassword)
  except ValueError:
    return false
