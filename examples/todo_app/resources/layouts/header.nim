import ../../../../src/basolato/view

proc impl(auth:Auth):string = tmpli html"""
$if auth.isLogin(){
  <div>
    <p>Login: $(auth.get("name"))</p>
  </div>
}
"""

proc headerView*(this:View):string =
  return impl(this.auth)