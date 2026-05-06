import std/json
import rustcrypto/algorithm/p256
import rustcrypto/algorithm/sha256
import rustcrypto/jwt as rustJwt

export rustJwt

const DefaultJwtAlgorithm* = jwtHS256

proc ecJwkFromSecret(secretKey: P256SecretKey): Jwk

proc base64UrlEncode(data: openArray[byte]): string =
  const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  result = newStringOfCap((data.len * 4 + 2) div 3)
  var i = 0
  while i < data.len:
    let b0 = uint32(data[i])
    let b1 = if i + 1 < data.len: uint32(data[i + 1]) else: 0'u32
    let b2 = if i + 2 < data.len: uint32(data[i + 2]) else: 0'u32
    let triple = (b0 shl 16) or (b1 shl 8) or b2
    result.add(alphabet[int((triple shr 18) and 0x3f)])
    result.add(alphabet[int((triple shr 12) and 0x3f)])
    if i + 1 < data.len:
      result.add(alphabet[int((triple shr 6) and 0x3f)])
    if i + 2 < data.len:
      result.add(alphabet[int(triple and 0x3f)])
    i += 3

proc deriveP256SecretKey(seed: string): P256SecretKey =
  var counter = 0
  while true:
    let digest = sha256("basolato-jwt-es256:" & seed & ":" & $counter)
    result = fixedArrayFromBytes[P256SecretKey](digest)
    try:
      discard P256.publicKeyCompressed(result)
      return
    except ValueError:
      inc counter

proc ecJwkFromSecret(secretKey: P256SecretKey): Jwk =
  let publicKey = P256.publicKeyUncompressed(secretKey)
  result.kty = "EC"
  result.crv = "P-256"
  result.x = base64UrlEncode(publicKey[1 .. 32])
  result.y = base64UrlEncode(publicKey[33 .. 64])
  result.d = base64UrlEncode(secretKey)

proc secretKey*(_: type Jwt, algorithm: JwtAlgorithm, seed: string): Jwk =
  case algorithm
  of jwtES256:
    let secret = deriveP256SecretKey(seed)
    ecJwkFromSecret(secret)
  of jwtHS256:
    rustJwt.Jwt.secretKey(seed)
  of jwtEdDSA, jwtRS256, jwtPS256:
    raise newException(ValueError, "JWT seed-derived key is not supported for " & $algorithm)

proc signingKey*(_: type Jwt, seed: string): Jwk =
  Jwt.secretKey(DefaultJwtAlgorithm, seed)

proc verificationKey*(_: type Jwt, seed: string): Jwk =
  Jwt.publicKey(Jwt.signingKey(seed))

proc sign*(_: type Jwt, payload: JsonNode, seed: string): JwtCompact =
  Jwt.sign(DefaultJwtAlgorithm, payload, Jwt.signingKey(seed))

proc verify*(_: type Jwt, token: JwtCompact, seed: string): bool =
  try:
    Jwt.verify(DefaultJwtAlgorithm, Jwt.verificationKey(seed), token)
  except ValueError:
    false

proc verifyAndDecode*(_: type Jwt, token: JwtCompact, seed: string): tuple[payload: JsonNode, valid: bool] =
  if not Jwt.verify(token, seed):
    return (newJObject(), false)

  try:
    (Jwt.decode(token), true)
  except ValueError:
    (newJObject(), false)
