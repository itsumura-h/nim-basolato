import
  json,
  re,
  tables,
  strformat,
  strutils,
  unicode,
  times


type Validation* = ref object

func newValidation*():Validation =
  return Validation()


proc accepted(value:string):bool =
  if value == "yes" or value == "on" or value == "1" or value == "true":
    return true
  else:
    return false

proc accepted*(self:Validation, value:string):bool =
  return accepted(value)


proc after(a,b:DateTime):bool =
  return a > b

proc after*(self:Validation, a, b:DateTime):bool =
  return after(a, b)


proc afterOrEqual(a,b:DateTime):bool =
  return a >= b

proc afterOrEqual*(self:Validation, a, b:DateTime):bool =
  return afterOrEqual(a, b)


proc alpha(value:string):bool =
  for c in value:
    if not c.isAlphaAscii:
      return false
  return true

proc alpha*(self:Validation, value:string):bool =
  return alpha(value)


proc alphaDash(value:string):bool =
  for c in value:
    if not c.isAlphaNumeric and c != '-' and c != '_':
      return false
  return true

proc alphaDash*(self:Validation, value:string):bool =
  return alphaDash(value)


proc alphaNum(value:string):bool =
  for c in value:
    if not c.isAlphaNumeric:
      return false
  return true

proc alphaNum*(self:Validation, value:string):bool =
  return alphaNum(value)


proc array*(value:string):bool =
  return value.match(re"^(?=.*\w,)(?!.*(=|\{|\})).*$")

proc array*(self:Validation, value:string):bool =
  return array(value)


proc before(a,b:DateTime):bool =
  return a < b

proc before*(self:Validation, a, b:DateTime):bool =
  return before(a, b)


proc beforeOrEqual(a,b:DateTime):bool =
  return a <= b

proc beforeOrEqual*(self:Validation, a, b:DateTime):bool =
  return beforeOrEqual(a, b)


proc between(value, min, max:int|float):bool =
  return min.float <= value.float and value.float <= max.float

proc between*(self:Validation, value, min, max:int|float):bool =
  return between(value, min, max)


proc between(value:string, min, max:int):bool =
  return min <= value.runeLen and value.runeLen <= max

proc between*(self:Validation, value:string, min, max:int):bool =
  return between(value, min, max)


proc between(value:openArray[string], min, max:int):bool =
  return min <= value.len and value.len <= max

proc between*(self:Validation, value:openArray[string], min, max:int):bool =
  return between(value, min, max)


proc betweenFile(value:string, min, max:int):bool =
  return min*1024 <= value.len and value.len <= max*1024

proc betweenFile*(self:Validation, value:string, min, max:int):bool =
  return betweenFile(value, min, max)


proc boolean(value:string):bool =
  try:
    discard value.parseBool
    return true
  except:
    return false

proc boolean*(self:Validation, value:string):bool =
  return boolean(value)


proc date(value, format:string):bool =
  try:
    discard value.parse(format)
    return true
  except:
    return false

proc date*(self:Validation, value, format:string):bool =
  return date(value, format)


proc date(value:string):bool =
  try:
    if value[0] == '-':
      raise newException(Exception, "")
    discard value.parseBiggestUInt.int.fromUnix
    return true
  except:
    return false

proc date*(self:Validation, value:string):bool =
  return date(value)


proc dateEquals(value, format:string, target:DateTime):bool =
  try:
    let valDt = value.parse(format)
    return valDt.month == target.month and valDt.monthday == target.monthday
  except:
    return false

proc dateEquals*(self:Validation, value, format:string, target:DateTime):bool =
  return dateEquals(value, format, target)

proc dateEquals(value:string, target:DateTime):bool =
  try:
    if value[0] == '-':
      raise newException(Exception, "")
    let valDt = value.parseBiggestUInt.int.fromUnix.utc
    return valDt.month == target.month and valDt.monthday == target.monthday
  except:
    return false

proc dateEquals*(self:Validation, value:string, target:DateTime):bool =
  return dateEquals(value, target)


proc different(a,b:string):bool =
  return a != b

proc different*(self:Validation, a, b:string):bool =
  return different(a, b)


proc digits(value:SomeInteger, digit:int):bool =
  return value.`$`.runeLen == digit

proc digits*(self:Validation, value:SomeInteger, digit:int):bool =
  return digits(value, digit)


proc digitsBetween(value:SomeInteger, min, max:int):bool =
  let length = value.`$`.runeLen
  return min <= length and length <= max

proc digitsBetween*(self:Validation, value:SomeInteger, min, max:int):bool =
  return digitsBetween(value, min, max)


proc distinctArr(values:openArray[string]):bool =
  var tmp = newSeq[string](values.len)
  for i, row in values:
    if tmp.contains(row):
      return false
    else:
      tmp[i] = row
  return true

proc distinctArr*(self:Validation, values:openArray[string]):bool =
  return distinctArr(values)


proc domain(value:string):bool =
  try:
    block:
      # let fqdn = re"^(([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])\.)*([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}?[a-z0-9])$"
      let fqdn = re"^(([a-zA-Z0-9]{1,2}|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])\.)*([a-zA-Z0-9]{1,2}|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}?[a-zA-Z0-9])$"
      let addr4 = re"(([01]?[0-9]{1,2}|2(?:[0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))"
      let addr4Start = re"^(([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))$"
      if value.len == 0 or value.len > 255:
        raise newException(Exception, "domain part is missing")
      if not value.startsWith("["):
        if not (not value.match(addr4) and value.match(fqdn)):
          raise newException(Exception, "invalid domain format")
        elif value.find(re"\.[0-9]$|^[0-9]+$") > -1:
          raise newException(Exception, "the last label of domain should not number")
        else:
          break
      if not value.endsWith("]"):
        raise newException(Exception, "domain lacks ']'")
      var value = value
      value.removePrefix("[")
      value.removeSuffix("]")
      if value.match(addr4Start):
        if value != "0.0.0.0":
          break
        else:
          raise newException(Exception, "domain 0.0.0.0 is invalid")
      if value.endsWith("::"):
        raise newException(Exception, "IPv6 should not end with '::'")
      var v4_flg = false
      var last = ""
      try:
        last = value.rsplit(":", maxsplit=1)[^1]
      except:
        raise newException(Exception, "invalid domain")
      if last.match(addr4):
        if value == "0.0.0.0":
          raise newException(Exception, "domain 0.0.0.0 is invalid")
        value = value.replace(last, "0:0")
        v4_flg = true
      var oc:int
      if value.contains("::"):
        oc = 8 - value.count(":")
        if oc < 1:
          raise newException(Exception, "8 blocks is required for IPv6")
        var ocStr = "0:"
        value = value.replace("::", &":{ocStr.repeat(oc)}")
        if value.startsWith(":"):
          value = &"0{value}"
        if value.endsWith(":"):
          value = &"{value}0"
      var elems = value.split(":")
      if elems.len != 8:
        raise newException(Exception, "invalid IP address")
      var res = 0
      for i, a in elems:
        if a.len > 4:
          raise newException(Exception, "each blick of IP address should be shorter than 4")
        try:
          res += a.parseHexInt shl ((7 - i) * 16)
        except:
          raise newException(Exception, "invalid IPv6 address")
      if not (res != 0 and (not v4_flg or res shr 32 == 0xffff)):
        raise newException(Exception, "invalid IPv4-Mapped IPv6 address")
  except:
    return false
  return true

proc domain*(self:Validation, value:string):bool =
  return domain(value)


proc email(value:string):bool =
  ## references https://gist.github.com/frodo821/681869a36148b5214632166e0ad293a9
  var value = value
  try:
    let valid = "abcdefghijklmnopqrstuvwxyz1234567890!#$%&\'*+-/=?^_`{}|~"
    if value.len == 0:
      raise newException(Exception, "email is empty")
    value = value.toLowerAscii()
    if not value.contains("@"):
      raise newException(Exception, "email should have '@'")
    var i:int
    if value.startsWith("\""):
      i = 1
      while i < min(64, value.len):
        if (valid & "()<>[]:;@,. ").contains(value[i]):
          i.inc()
          continue
        if $value[i] == "\\":
          if value[i+1..^1].len > 0 and (valid & """()<>[]:;@,.\\" """).contains($value[i+1]):
            i.inc(2)
            continue
          raise newException(Exception, "invalid email format")
        if value[i] == '"':
          break
      if i == 64:
        i.dec()
      if not (value[i+1..^1].len > 0 and $value[i+1] == "@"):
        raise newException(Exception, "invalid email local-part")
      return domain(value[i+2..^1])
    else:
      i = 0
      while i < min(64, value.len):
        if valid.contains(value[i]):
          i.inc()
          continue
        if $value[i] == ".":
          if i == 0 or value[i+1..^1].len == 0 or ".@".contains(value[i+1]):
            raise newException(Exception, "invalid email local-part")
          i.inc()
          continue
        if $value[i] == "@":
          if i == 0:
            raise newException(Exception, "email has no local-part")
          i.dec()
          break
        raise newException(Exception, "email includes invalid char")
      if i == 64:
        i.dec
      if not (value[i+1..^1].len > 0 and "@".contains(value[i+1])):
        raise newException(Exception, "email local-part should be shorter than 64")
      return domain(value[i+2..^1])
  except:
    return false
  return true

proc email*(self:Validation, value:string):bool =
  return email(value)


proc endsWith(value:string, expects:openArray[string]):bool =
  result = false
  for expect in expects:
    let endWidth = expect.len
    return value[value.len - endWidth..^1] == expect

proc endsWith*(self:Validation, value:string, expects:openArray[string]):bool =
  return endsWith(value, expects)


proc file(value, ext:string):bool =
  return value.len > 0 and ext.len > 0

proc file*(self:Validation, value, ext:string):bool =
  return file(value, ext)


proc filled(value:string):bool =
  return value.len > 0

proc filled*(self:Validation, value:string):bool =
  return filled(value)


proc gt(a, b:SomeInteger):bool =
  return a > b

proc gt*(self:Validation, a, b:SomeInteger):bool =
  return gt(a, b)


proc gt(a, b:string):bool =
  return a.len > b.len

proc gt*(self:Validation, a, b:string):bool =
  return gt(a, b)


proc gt(a, b:openArray[string]):bool =
  return a.len > b.len

proc gt*(self:Validation, a, b:openArray[string]):bool =
  return gt(a, b)


proc gte(a, b:SomeInteger):bool =
  return a >= b

proc gte*(self:Validation, a, b:SomeInteger):bool =
  return gte(a, b)


proc gte(a, b:string):bool =
  return a.len >= b.len

proc gte*(self:Validation, a, b:string):bool =
  return gte(a, b)


proc gte(a, b:openArray[string]):bool =
  return a.len >= b.len

proc gte*(self:Validation, a, b:openArray[string]):bool =
  return gte(a, b)


proc image(ext:string):bool =
  return ["jpg", "jpeg", "png", "gif", "bmp", "svg", "webp"].contains(ext)

proc image*(self:Validation, ext:string):bool =
  return image(ext)


proc `in`(value:string, list:openArray[string]):bool =
  return list.contains(value)

proc `in`*(self:Validation, value:string, list:openArray[string]):bool =
  return `in`(value, list)


proc integer(value:string):bool =
  for c in value:
    if not c.isDigit:
      return false
  return true

proc integer*(self:Validation, value:string):bool =
  return integer(value)


proc json(value:string):bool =
  try:
    discard value.parseJson
    return true
  except:
    return false

proc json*(self:Validation, value:string):bool =
  return json(value)


proc lt(a, b:SomeInteger):bool =
  return a < b

proc lt*(self:Validation, a, b:SomeInteger):bool =
  return lt(a, b)


proc lt(a, b:string):bool =
  return a.len < b.len

proc lt*(self:Validation, a, b:string):bool =
  return lt(a, b)


proc lt(a, b:openArray[string]):bool =
  return a.len < b.len

proc lt*(self:Validation, a, b:openArray[string]):bool =
  return lt(a, b)


proc lte(a, b:SomeInteger):bool =
  return a <= b

proc lte*(self:Validation, a, b:SomeInteger):bool =
  return lte(a, b)


proc lte(a, b:string):bool =
  return a.len <= b.len

proc lte*(self:Validation, a, b:string):bool =
  return lte(a, b)


proc lte(a, b:openArray[string]):bool =
  return a.len <= b.len

proc lte*(self:Validation, a, b:openArray[string]):bool =
  return lte(a, b)


proc maxValidate(value:SomeInteger, maximum:int):bool =
  return value <= maximum

proc max*(self:Validation, value:SomeInteger, maximum:int):bool =
  return maxValidate(value, maximum)


proc maxFileValidate(value:string, maximum:int):bool =
  return value.len <= (maximum*1024)

proc maxFile*(self:Validation, value:string, maximum:int):bool =
  return maxFileValidate(value, maximum)


proc maxValidate(value:string, maximum:int):bool =
  return value.len <= maximum

proc max*(self:Validation, value:string, maximum:int):bool =
  return maxValidate(value, maximum)


proc maxValidate(value:openArray[string], maximum:int):bool =
  return value.len <= maximum

proc max*(self:Validation, value:openArray[string], maximum:int):bool =
  return maxValidate(value, maximum)


proc mimes(ext:string, types:openArray[string]):bool =
  return types.contains(ext)

proc mimes*(self:Validation, ext:string, types:openArray[string]):bool =
  return mimes(ext, types)


proc minValidate(value:SomeInteger, minimum:int):bool =
  return value >= minimum

proc min*(self:Validation, value:SomeInteger, minimum:int):bool =
  return minValidate(value, minimum)


proc minFileValidate(value:string, minimum:int):bool =
  return value.len >= (minimum*1024)

proc minFile*(self:Validation, value:string, minimum:int):bool =
  return minFileValidate(value, minimum)


proc minValidate(value:string, minimum:int):bool =
  return value.len >= minimum

proc min*(self:Validation, value:string, minimum:int):bool =
  return minValidate(value, minimum)


proc minValidate(value:openArray[string], minimum:int):bool =
  return value.len >= minimum

proc min*(self:Validation, value:openArray[string], minimum:int):bool =
  return minValidate(value, minimum)


proc `notIn`(value:string, list:openArray[string]):bool =
  return not list.contains(value)

proc `notIn`*(self:Validation, value:string, list:openArray[string]):bool =
  return `notIn`(value, list)


proc notRegex(value:string, reg:Regex):bool =
  return not value.match(reg)

proc notRegex*(self:Validation, value:string, reg:Regex):bool =
  return notRegex(value, reg)


proc numeric(value:string):bool =
  var value = value
  if value[0] == '-':
    value = value[1..^1]
  for c in value:
    if not c.isDigit and c != '.':
      return false
  return true

proc numeric*(self:Validation, value:string):bool =
  return numeric(value)

proc password(value:string):bool =
  return value.match(re"^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[a-zA-Z\d]{8,100}$")

proc password*(self:Validation, value:string):bool =
  password(value)

proc regex(value:string, reg:Regex):bool =
  return value.match(reg)

proc regex*(self:Validation, value:string, reg:Regex):bool =
  return regex(value, reg)


proc required(value:string):bool =
  return value.len > 0 and value != "null"

proc required*(self:Validation, value:string):bool =
  return required(value)


proc same(a, b:string):bool =
  return a == b

proc same*(self:Validation, a, b:string):bool =
  return same(a, b)


proc size(value:int, standard:int):bool =
  return value == standard

proc size*(self:Validation, value:int, standard:int):bool =
  return size(value, standard)


proc sizeFile(value:string, standard:int):bool =
  return (value.len div 1024) == standard

proc sizeFile*(self:Validation, value:string, standard:int):bool =
  return sizeFile(value, standard)


proc size(value:string, standard:int):bool =
  return value.runeLen == standard

proc size*(self:Validation, value:string, standard:int):bool =
  return size(value, standard)


proc size(value:openArray[string], standard:int):bool =
  return value.len == standard

proc size*(self:Validation, value:openArray[string], standard:int):bool =
  return size(value, standard)


proc startsWith(value:string, targets:openArray[string]):bool =
  for target in targets:
    if value[0..target.len-1] == target:
      return true
  return false

proc startsWith*(self:Validation, value:string, targets:openArray[string]):bool =
  return startsWith(value, targets)


proc url(value:string):bool =
  const protocolList = ["aaa", "aaas", "about", "acap", "acct", "acd", "acr", "adiumxtra", "adt", "afp", "afs", "aim", "amss", "android", "appdata", "apt", "ark", "attachment", "aw", "barion", "beshare", "bitcoin", "bitcoincash", "blob", "bolo", "browserext", "calculator", "callto", "cap", "cast", "casts", "chrome", "chrome-extension", "cid", "coap", "coap+tcp", "coap+ws", "coaps", "coaps+tcp", "coaps+ws", "com-eventbrite-attendee", "content", "conti", "crid", "cvs", "dab", "data", "dav", "diaspora", "dict", "did", "dis", "dlna-playcontainer", "dlna-playsingle", "dns", "dntp", "dpp", "drm", "drop", "dtn", "dvb", "ed2k", "elsi", "example", "facetime", "fax", "feed", "feedready", "file", "filesystem", "finger", "first-run-pen-experience", "fish", "fm", "ftp", "fuchsia-pkg", "geo", "gg", "git", "gizmoproject", "go", "gopher", "graph", "gtalk", "h323", "ham", "hcap", "hcp", "http", "https", "hxxp", "hxxps", "hydrazone", "iax", "icap", "icon", "im", "imap", "info", "iotdisco", "ipn", "ipp", "ipps", "irc", "irc6", "ircs", "iris", "iris.beep", "iris.lwz", "iris.xpc", "iris.xpcs", "isostore", "itms", "jabber", "jar", "jms", "keyparc", "lastfm", "ldap", "ldaps", "leaptofrogans", "lorawan", "lvlt", "magnet", "mailserver", "mailto", "maps", "market", "message", "mid", "mms", "modem", "mongodb", "moz", "ms-access", "ms-browser-extension", "ms-calculator", "ms-drive-to", "ms-enrollment", "ms-excel", "ms-eyecontrolspeech", "ms-gamebarservices", "ms-gamingoverlay", "ms-getoffice", "ms-help", "ms-infopath", "ms-inputapp", "ms-lockscreencomponent-config", "ms-media-stream-id", "ms-mixedrealitycapture", "ms-mobileplans", "ms-officeapp", "ms-people", "ms-project", "ms-powerpoint", "ms-publisher", "ms-restoretabcompanion", "ms-screenclip", "ms-screensketch", "ms-search", "ms-search-repair", "ms-secondary-screen-controller", "ms-secondary-screen-setup", "ms-settings", "ms-settings-airplanemode", "ms-settings-bluetooth", "ms-settings-camera", "ms-settings-cellular", "ms-settings-cloudstorage", "ms-settings-connectabledevices", "ms-settings-displays-topology", "ms-settings-emailandaccounts", "ms-settings-language", "ms-settings-location", "ms-settings-lock", "ms-settings-nfctransactions", "ms-settings-notifications", "ms-settings-power", "ms-settings-privacy", "ms-settings-proximity", "ms-settings-screenrotation", "ms-settings-wifi", "ms-settings-workplace", "ms-spd", "ms-sttoverlay", "ms-transit-to", "ms-useractivityset", "ms-virtualtouchpad", "ms-visio", "ms-walk-to", "ms-whiteboard", "ms-whiteboard-cmd", "ms-word", "msnim", "msrp", "msrps", "mss", "mtqp", "mumble", "mupdate", "mvn", "news", "nfs", "ni", "nih", "nntp", "notes", "ocf", "oid", "onenote", "onenote-cmd", "opaquelocktoken", "openpgp4fpr", "pack", "palm", "paparazzi", "payto", "pkcs11", "platform", "pop", "pres", "prospero", "proxy", "pwid", "psyc", "pttp", "qb", "query", "redis", "rediss", "reload", "res", "resource", "rmi", "rsync", "rtmfp", "rtmp", "rtsp", "rtsps", "rtspu", "s3", "secondlife", "service", "session", "sftp", "sgn", "shttp", "sieve", "simpleledger", "sip", "sips", "skype", "smb", "sms", "smtp", "snews", "snmp", "soap.beep", "soap.beeps", "soldat", "spiffe", "spotify", "ssh", "steam", "stun", "stuns", "submit", "svn", "tag", "teamspeak", "tel", "teliaeid", "telnet", "tftp", "tg", "things", "thismessage", "tip", "tn3270", "tool", "ts3server", "turn", "turns", "tv", "udp", "unreal", "urn", "ut2004", "v-event", "vemmi", "ventrilo", "videotex", "vnc", "view-source", "wais", "webcal", "wpid", "ws", "wss", "wtai", "wyciwyg", "xcon", "xcon-userid", "xfire", "xmlrpc.beep", "xmlrpc.beeps", "xmpp", "xri", "ymsgr", "z39.50", "z39.50r", "z39.50s"]
  let protocol = value.split("://")[0]
  if not protocolList.contains(protocol):
    return false

  var domainStr = value.split("://")[1].split("/")[0]
  if domainStr.contains(":"):
    let port = domainStr.split(":")[1]
    if not port.numeric():
      return false
    domainStr = domainStr.split(":")[0]
  if not domain(domainStr):
    return false

  let path = value.split("://")[1].split("/")[1..^1].join("/")
  let reg = re"^(?:[\pL\pN\-._\~!$&\'()*+,;=:@\/?]|%[0-9A-Fa-f]{2})*$"
  if not path.match(reg):
    return false
  return true

proc url*(self:Validation, value:string):bool =
  return url(value)


proc uuid(value:string):bool =
  let reg = re"^[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}$"
  return value.match(reg)

proc uuid*(self:Validation, value:string):bool =
  return uuid(value)
