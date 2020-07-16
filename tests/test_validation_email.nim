import unittest, tables, json, times, strutils, strformat
import ../src/basolato/request_validation

const valid_addresses = [
  {"email": "email@domain.com"}.toTable(),
  {"email": "firstname.lastname@domain.com"}.toTable(),
  {"email": "email@subdomain.domain.com"}.toTable(),
  {"email": "firstname+lastname@domain.com"}.toTable(),
  {"email": "1234567890@domain.com"}.toTable(),
  {"email": "_______@domain.com"}.toTable(),
  {"email": "firstname-lastname@domain.com"}.toTable(),
  {"email": "-email@domain"}.toTable(),
  {"email": "abcABC123.defDEF456@ghiGHI789.comCOM012"}.toTable(),
  {"email": "abc.#%&'/=~`*+?{}^$-|@ghi.com"}.toTable(),
  {"email": "Abc@example.com"}.toTable(),
  {"email": "Abc.123@example.com"}.toTable(),
  {"email": "user+mailbox/department=shipping@example.com"}.toTable(),
  {"email": "customer/department=shipping@example.com"}.toTable(),
  {"email": "!#$%&'*+-/=?^_`.{|}~@example.com"}.toTable(),
  {"email": "!def!xyz%abc@example.com"}.toTable(),
  {"email": """"e#$$%&@>mail"@domain.com"""}.toTable(),
  {"email": """"em,ail"@localhost"""}.toTable(),
  {"email": """"Abc@def"@example.com"""}.toTable(),
  {"email": """"Fred\ Bloggs"@example.com"""}.toTable(),
  {"email": """"Joe.\\Blow"@example.com"""}.toTable(),
  {"email": """"Joe.\"Blow"@example.com"""}.toTable(),
  {"email": """".dot_kara_hazimaru"@example.com"""}.toTable(),
  {"email": """"I.likeyou."@example.com"""}.toTable(),
  {"email": """"I..love...you"@example.com"""}.toTable(),
  {"email": "email@domain-one.com"}.toTable(),
  {"email": "email@domain.co.jp"}.toTable(),
  {"email": "email@localhost"}.toTable(),
  {"email": "a@a"}.toTable(),
  {"email": "a@0.a"}.toTable(),
  {"email": "a@a-a.com"}.toTable(),
  {"email": "a@0-a.com"}.toTable(),
  {"email": "a@a-0.com"}.toTable(),
  {"email": "a@a-a.a-a"}.toTable(),
  {"email": "email@[123.123.123.123]"}.toTable(),
  {"email": "a@[255.255.255.255]"}.toTable(),
  {"email": "a@[001.002.003.004]"}.toTable(),
  {"email": "a@[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]"}.toTable(),
  {"email": "a@[2001:db8:20:3:1000:100:20:3]"}.toTable(),
  {"email": "a@[2001:db8::1234:0:0:9abc]"}.toTable(),
  {"email": "a@[2001:db8::9abc]"}.toTable(),
  {"email": "a@[::1]"}.toTable(),
  {"email": "ea@[::ffff:255.255.255.255]"}.toTable(),
  # # 63 byte ok
  {"email": "a@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.com"}.toTable(),
  # 64 byte ok
  {"email": "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/@example.com"}.toTable(),
  # local-part limitation OK
  {"email": """"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567+/"@example.com"""}.toTable(),
  # # 252 octet OK
  {"email": "abcdefhghijklmnopqrstuvwxyzABC@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23"}.toTable(),
  {"email": "a@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23"}.toTable(),
  # # domain 255 OK
  {"email": "abcdefhghijklmnopqrstuvwxyzABCD@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz"}.toTable(),
  {"email": "a@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz"}.toTable(),
  {"email": """"abcdefhghijklmnopqrstuvwxyzABC"@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com"""}.toTable(),
  {"email": """"abcdefhghijklmnopqrstuvwxyzABCD"@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com"""}.toTable(),
]

const invalid_addresses = [
  {"email": "Abc.@example.com"}.toTable(),
  {"email": "Abc..123@example.com"}.toTable(),
  {"email": ".dot_kara_hazimaru@example.com"}.toTable(),
  {"email": "I.like.you.@example.com"}.toTable(),
  {"email": "I..love...you@example.com"}.toTable(),
  {"email": "abc.def@#%&'/=~`*+?{}^$-|.com"}.toTable(),
  {"email": "ab<c.def@ghi.com"}.toTable(),
  {"email": "abc.de<f@ghi.com"}.toTable(),
  {"email": ".email@domain.com"}.toTable(),
  {"email": "email.@domain.com"}.toTable(),
  {"email": "email..email@domain.com"}.toTable(),
  {"email": "あいうえお@domain.com"}.toTable(),
  {"email": "email@-domain.com"}.toTable(),
  {"email": "email@-.-.-.-"}.toTable(),
  {"email": "email@123.123.123.123"}.toTable(),
  {"email": "abc.def@ghi.#%&'/=~`*+?{}^$-|"}.toTable(),
  {"email": "abc.def@gh<i.com"}.toTable(),
  {"email": "abc.def@ghi.co<m"}.toTable(),
  # --
  {"email": "a@0"}.toTable(),
  {"email": "a@0.0"}.toTable(),
  {"email": "a@a.0"}.toTable(),
  # --
  {"email": "a@.a"}.toTable(),
  {"email": "a@a-.a"}.toTable(),
  {"email": "a@-a.a"}.toTable(),
  {"email": "email@domain..com"}.toTable(),
  {"email": "email@[111.222.333.44444]"}.toTable(),
  {"email": "a@[example.com]"}.toTable(),
  {"email": "a@[example.com:hoge]"}.toTable(),
  {"email": "a@[fuga:xxxxxxx]"}.toTable(),
  {"email": "a@[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]"}.toTable(),
  {"email": "a@[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee:11fe]"}.toTable(),
  {"email": "a@[::]"}.toTable(),
  {"email": "a@[1::]"}.toTable(),
  {"email": "a@[1:2:3:4:5:6:7::]"}.toTable(),
  {"email": "a@[::255.255.255.255]"}.toTable(),
  {"email": "a@[2001:db8:3:4::192.0.2.33]"}.toTable(),
  {"email": "a@[64:ff9b::192.0.2.33]"}.toTable(),
  # # 64 byte NG
  {"email": "a@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678901.com"}.toTable(),
  # # 65 byte NG
  {"email": "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/a@example.com"}.toTable(),
  # # 65 byte NG
  {"email": """"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567+/a"@example.com"""}.toTable(),
  # domain 256 NG
  {"email": "abcdefhghijklmnopqrstuvwxyzABCD@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zzz"}.toTable(),
  {"email": "plainaddress"}.toTable(),
  {"email": "@domain.com"}.toTable(),
  {"email": "Joe Smith <email@domain.com>"}.toTable(),
  {"email": "email.domain.com"}.toTable(),
  {"email": "email@domain@domain.com"}.toTable(),
  {"email": "email@domain.com (Joe Smith)"}.toTable(),
  {"email": "email@ example"}.toTable(),
  {"email": """"foo"."bar"@example.com"""}.toTable(),
  # add test
  {"email": "email@[0.0.0.0]"}.toTable(),
  {"email": "email@[1111.1111.1111.11111]"}.toTable(),
]


suite "email valid":
  test "strictEmail":
    for address in valid_addresses:
      var v = RequestValidation(params: address,
                          errors: newJObject())
      v.strictEmail("email")
      v.valid()
      echo address["email"]
      echo v.errors
      check v.errors.len == 0

  test "strictEmail invalid":
    for address in invalid_addresses:
      var v = RequestValidation(params: address,
                          errors: newJObject())
      v.strictEmail("email")
      try:
        v.valid()
      except:
        echo address["email"]
        echo v.errors["email"]
        check v.errors.len > 0

  test "DOS Attack":
    for n in 5..12:
      var s = "username@host" & ".abcde".repeat(n) & "."
      var start = now()
      var v = RequestValidation(params: {"email": s}.toTable,
                          errors: newJObject())
      v.strictEmail("email")
      try:
        v.valid()
      except:
        var diff = now() - start
        debugEcho "--------------"
        debugEcho s
        echo &"{s.len}: {diff.seconds}.{diff.milliseconds:04}{diff.microseconds:04}"
