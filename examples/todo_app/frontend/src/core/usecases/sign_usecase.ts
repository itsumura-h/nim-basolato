import {goto} from '@sapper/app'
// import request from '../libs/api'
import {AxiosRequest} from '../libs/api_request'

export default class SignUsecase{

  async signin(email, password:string):Promise<string>{
    let params = {
      email: email,
      password: password
    }
    let request = new AxiosRequest
    request.post("/signin", params)
    .then(response=>{
      sessionStorage.setItem('isLogin', 'true')
      goto('/')
    })
    .catch(err=>{
      return err.response.data.error
    })
  }

  async signout(){
    let request = new AxiosRequest
    // await request.delete('/signout')
    sessionStorage.removeItem('isLogin')
    goto('/signin')
  }
}