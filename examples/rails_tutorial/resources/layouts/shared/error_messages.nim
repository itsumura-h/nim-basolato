import json
import basolato/view

proc error_messages*(errors:JsonNode):string = tmpli html"""
$if errors.len > 0 {
  <div id="error_explanation">
    <div class="alert alert-danger">
      The form contains $(errors.len) erros
    </div>
    $for key, val in errors{
      $key
      <ul>
        $for row in val {
          <li>$(row.get)</li>
        }
      </ul>
    }
  </div>
}
"""
