#? stdtmpl | standard
#import json
#import ../base
#import createImpl
#import ../../../src/basolato/view
#proc createHtml*(auth:Auth, email="", errors=newJObject()): string =
${baseHtml(auth, createHtmlImpl(email, errors))}
