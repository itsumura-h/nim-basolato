import std/json
import std/base64
import std/strutils
import nimcrypto; export hmacSizeBlock
import ../logger


type JwtAlgorism* = enum
  es128 = "ES128",
  es192 = "ES192",
  es256 = "ES256",
  es384 = "ES384",
  es512 = "ES512",
  hs128 = "HS128",
  hs192 = "HS192",
  hs256 = "HS256",
  hs384 = "HS384",
  hs512 = "HS512",
  ps128 = "PS128",
  ps192 = "PS192",
  ps256 = "PS256",
  ps384 = "PS384",
  ps512 = "PS512",
  rs128 = "RS128",
  rs192 = "RS192",
  rs256 = "RS256",
  rs384 = "RS384",
  rs512 = "RS512"
  none = "none"


proc base64UrlEncode(input: string): string =
  let encoded = base64.encode(input)
  return encoded.replace('+', '-').replace('/', '_').replace("=", "")

proc base64UrlDecode(input:string):string =
  let paddingNeeded = (4 - input.len mod 4) mod 4
  let normalizedInput = input & repeat('=', paddingNeeded)
  let decodedBytes = base64.decode(normalizedInput.replace('-', '+').replace('_', '/'))
  return decodedBytes


type Jwt* = object

proc encode*(_: type Jwt, payload: string, secretKey: string, algorithm: JwtAlgorism = JwtAlgorism.hs256): string =
  let header = %*{
    "alg": $algorithm,
    "typ": "JWT"
  }

  let header64 = base64UrlEncode($header)
  let payload64 = base64UrlEncode(payload)
  let signatureInput = header64 & "." & payload64
  var signature: string

  case algorithm
  of hs256:
    signature = base64UrlEncode($sha256.hmac(secretKey, signatureInput))
  of hs384:
    signature = base64UrlEncode($sha384.hmac(secretKey, signatureInput))
  of hs512:
    signature = base64UrlEncode($sha512.hmac(secretKey, signatureInput))
  else:
    signature = ""

  return signatureInput & "." &  signature


proc decode*(_: type Jwt, token: string, secretKey: string): (JsonNode, bool) =
  ## return (payload:JsonNode, valid:bool)

  # Split the token into its components
  let parts = token.split('.')
  if parts.len != 3:
    # raise newException(ValueError, "Invalid JWT token.")
    echoErrorMsg("Invalid JWT token.")
    return (newJObject(), false)

  let header64 = parts[0]
  let payload64 = parts[1]
  let signature64 = parts[2]

  # Decode the header and payload
  let headerJson = parseJson(base64UrlDecode(header64))
  let payloadJson = parseJson(base64UrlDecode(payload64))

  # Verify the algorithm
  let alg = headerJson["alg"].getStr
  var algorithm: JwtAlgorism

  case alg:
  of "HS256": algorithm = hs256
  of "HS384": algorithm = hs384
  of "HS512": algorithm = hs512
  # Add further algorithm cases here as needed
  else:
    echoErrorMsg("Unrecognized or unsupported algorithm: " & alg)
    raise newException(ValueError, "Unrecognized or unsupported algorithm: " & alg)
  
  let signatureInput = header64 & "." & payload64
  var expectedSignature: string

  # Compute the expected signature using the secret key and algorithm
  case algorithm:
  of hs256:
    expectedSignature = base64UrlEncode($sha256.hmac(secretKey, signatureInput))
  of hs384:
    expectedSignature = base64UrlEncode($sha384.hmac(secretKey, signatureInput))
  of hs512:
    expectedSignature = base64UrlEncode($sha512.hmac(secretKey, signatureInput))
  else:
    expectedSignature = ""

  if expectedSignature != signature64:
    return (newJObject(), false)

  return (payloadJson, true)
