#? stdtmpl | standard
#import json
#import ../base
#import ../../../src/basolato/view
#import createImpl
#proc createHtml*(auth:Auth, name="", email="", errors=newJObject()): string =
  ${baseHtml(auth, createHtmlImpl(name, email, errors))}
