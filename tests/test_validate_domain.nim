import unittest
include ../src/basolato/core/validation

const validDomains = [
  "domain.com",
  "subdomain.domain.com",
  "domain",
  "ghiGHI789.comCOM012",
  "ghi.com",
  "example.com",
  "localhost",
  "domain-one.com",
  "domain.co.jp",
  "a",
  "0.a",
  "a-a.com",
  "0-a.com",
  "a-0.com",
  "a-a.a-a",
  "[123.123.123.123]",
  "[255.255.255.255]",
  "[001.002.003.004]",
  "[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]",
  "[2001:db8:20:3:1000:100:20:3]",
  "[2001:db8::1234:0:0:9abc]",
  "[2001:db8::9abc]",
  "[::1]",
  "[::ffff:255.255.255.255]",
  # 63 byte ok
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.com",
  # # 252 octet OK
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23",
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23",
  # domain 255 OK
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz",
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz",
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com",
  "aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com",
]

block:
  let v = newValidation()
  for validDomain in validDomains:
    check v.domain(validDomain)

const validEmails = [
  "email@domain.com",
  "firstname.lastname@domain.com",
  "email@subdomain.domain.com",
  "firstname+lastname@domain.com",
  "1234567890@domain.com",
  "_______@domain.com",
  "firstname-lastname@domain.com",
  "-email@domain",
  "abcABC123.defDEF456@ghiGHI789.comCOM012",
  "abc.#%&'/=~`*+?{}^$-|@ghi.com",
  "Abc@example.com",
  "Abc.123@example.com",
  "user+mailbox/department=shipping@example.com",
  "customer/department=shipping@example.com",
  "!#$%&'*+-/=?^_`.{|}~@example.com",
  "!def!xyz%abc@example.com",
  """"e#$$%&@>mail"@domain.com""",
  """"em,ail"@localhost""",
  """"Abc@def"@example.com""",
  """"Fred\ Bloggs"@example.com""",
  """"Joe.\\Blow"@example.com""",
  """"Joe.\"Blow"@example.com""",
  """".dot_kara_hazimaru"@example.com""",
  """"I.likeyou."@example.com""",
  """"I..love...you"@example.com""",
  "email@domain-one.com",
  "email@domain.co.jp",
  "email@localhost",
  "a@a",
  "a@0.a",
  "a@a-a.com",
  "a@0-a.com",
  "a@a-0.com",
  "a@a-a.a-a",
  "email@[123.123.123.123]",
  "a@[255.255.255.255]",
  "a@[001.002.003.004]",
  "a@[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee]",
  "a@[2001:db8:20:3:1000:100:20:3]",
  "a@[2001:db8::1234:0:0:9abc]",
  "a@[2001:db8::9abc]",
  "a@[::1]",
  "ea@[::ffff:255.255.255.255]",
  # # 63 byte ok
  "a@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890.com",
  # 64 byte ok
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/@example.com",
  # local-part limitation OK
  """"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567+/"@example.com""",
  # # 252 octet OK
  "abcdefhghijklmnopqrstuvwxyzABC@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23",
  "a@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23",
  # # domain 255 OK
  "abcdefhghijklmnopqrstuvwxyzABCD@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz",
  "a@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zz",
  """"abcdefhghijklmnopqrstuvwxyzABC"@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com""",
  """"abcdefhghijklmnopqrstuvwxyzABCD"@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.com""",
]

const invalidEmails = [
  "Abc.@example.com",
  "Abc..123@example.com",
  ".dot_kara_hazimaru@example.com",
  "I.like.you.@example.com",
  "I..love...you@example.com",
  "abc.def@#%&'/=~`*+?{}^$-|.com",
  "ab<c.def@ghi.com",
  "abc.de<f@ghi.com",
  ".email@domain.com",
  "email.@domain.com",
  "email..email@domain.com",
  "あいうえお@domain.com",
  "email@-domain.com",
  "email@-.-.-.-",
  "email@123.123.123.123",
  "abc.def@ghi.#%&'/=~`*+?{}^$-|",
  "abc.def@gh<i.com",
  "abc.def@ghi.co<m",
  # --
  "a@0",
  "a@0.0",
  "a@a.0",
  # --
  "a@.a",
  "a@a-.a",
  "a@-a.a",
  "email@domain..com",
  "email@[111.222.333.44444]",
  "a@[example.com]",
  "a@[example.com:hoge]",
  "a@[fuga:xxxxxxx]",
  "a@[2001:0db8:bd05:01d2:288a::1fc0:0001:10ee]",
  "a@[2001:0db8:bd05:01d2:288a:1fc0:0001:10ee:11fe]",
  "a@[::]",
  "a@[1::]",
  "a@[1:2:3:4:5:6:7::]",
  "a@[::255.255.255.255]",
  "a@[2001:db8:3:4::192.0.2.33]",
  "a@[64:ff9b::192.0.2.33]",
  # # 64 byte NG
  "a@abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ012345678901.com",
  # # 65 byte NG
  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/a@example.com",
  # # 65 byte NG
  """"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567+/a"@example.com""",
  # domain 256 NG
  "abcdefhghijklmnopqrstuvwxyzABCD@aaaaaaaa01.aaaaaaaa02.aaaaaaaa03.aaaaaaaa04.aaaaaaaa05.aaaaaaaa06.aaaaaaaa07.aaaaaaaa08.aaaaaaaa09.aaaaaaaa10.aaaaaaaa11.aaaaaaaa12.aaaaaaaa13.aaaaaaaa14.aaaaaaaa15.aaaaaaaa16.aaaaaaaa17.aaaaaaaa18.aaaaaaaa19.aaaaaaaa20.aaaaaaaa21.aaaaaaaa22.aaaaaaaa23.zzz",
  "plainaddress",
  "@domain.com",
  "Joe Smith <email@domain.com>",
  "email.domain.com",
  "email@domain@domain.com",
  "email@domain.com (Joe Smith)",
  "email@ example",
  """"foo"."bar"@example.com""",
  # add test
  "email@[0.0.0.0]",
  "email@[1111.1111.1111.11111]",
]

block:
  let v = newValidation()
  for validEmail in validEmails:
    check v.email(validEmail)

  for invalidEmail in invalidEmails:
    check v.email(invalidEmail) == false
