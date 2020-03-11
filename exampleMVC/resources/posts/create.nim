#? stdtmpl | standard
#import json
#import ../../../src/basolato/view
#import ../base
#import createImpl
#proc createHtml*(auth:Auth, title="", text="", errors=newJObject()): string =
${baseHtml(auth, createHtmlImpl(title, text, errors))}
