import templates

proc indexHtml*(name:string): string = tmpli html"""
<h1>$(name) is successfully running!!!</h1>
"""
