import {replace} from 'svelte-spa-router'
import axios from "axios"

export default class SignUsecase{
  config: object
  
  constructor(){
    this.config = {
      withCredentials: true
    }
  }

  signin(email, password:string):string{
    let params = {
      email: email,
      password: password
    }
    return axios.post("http://localhost:9000/api/signin", params, this.config)
    .then(response=>{
      sessionStorage.setItem('isLogin', 'true')
      replace('/')
      return ""
    })
    .catch(err=>{
      console.error(err)
      return err
    })
  }

  dataFetch():string{
    return axios.get("http://localhost:9000/api/signin-data", this.config)
    .then(response=>{
      return response.data["message"]
    })
    .catch(err=>{
      sessionStorage.removeItem('isLogin')
      replace('/signin')  
    })
  }
}