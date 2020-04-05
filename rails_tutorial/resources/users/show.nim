import json
import basolato/view

proc showHtml*(user:JsonNode):string = tmpli html"""
$(user["name"].get), $(user["email"].get)
"""
