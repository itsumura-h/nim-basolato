import {FetchRequest, AxiosRequest, Response} from '../libs/api_request'

export default class SignRepository{
  request: IApiRequest

  constructor(obj?:object){
    if(typeof obj === 'undefined'){
      this.request = new AxiosRequest
    }else{
      this.request = new FetchRequest(obj)
    }
  }

  async signin(email, password:string):Response{
    let params = {
      email: email,
      password: password
    }
    let res = await this.request.post("/signin", params)
    return res
  }

  async signout(){
    await this.request.delete('/signout')
  }
}