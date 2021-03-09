import request from "../libs/request"


export default class SignUsecase{

  async signin(email, password:string){
    let params = {
      email: email,
      password: password
    }
    return request.post("/signin", params)
    .then(response=>{
      sessionStorage.setItem('isLogin', 'true')
      $goto('/')
    })
    .catch(err=>{
      return err.response.data.error
    })
  }

  async signout(){
    await request.delete('/signout')
    sessionStorage.removeItem('isLogin')
    $goto('/signin')
  }
}