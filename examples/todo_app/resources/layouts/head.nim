import ../../../../src/basolato/view

proc headView*():string = tmpli html"""
$(csrf_token())
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
"""
