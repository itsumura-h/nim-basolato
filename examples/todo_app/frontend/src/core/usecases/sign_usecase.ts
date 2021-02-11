import {replace} from 'svelte-spa-router'
import axios from "axios";

export default class SignUsecase {
  signin(email, password:string):string{
    let params = {
      email: email,
      password: password
    }
    let config = {
      withCredentials: true,
    }
    return axios.post("http://localhost:9000/api/signin", params, config)
    .then(response=>{
      sessionStorage.setItem("x-login-token", response.headers["x-login-token"]);
      replace('/')
      return ""
    })
    .catch(err=>{
      console.log(err)
      return err
    })
  }

  dataFetch():string{
    console.log(sessionStorage.getItem('x-login-token'))
    let config = {
      withCredentials: true,
      headers: {
        'x-login-token': sessionStorage.getItem('x-login-token'),
      }
    }
    return axios.get("http://localhost:9000/api/signin-data", config)
    .then(response=>{
      return response.data["message"]
    })
    .catch(err=>{
      console.log(err)
      replace('/signin')
      return err
    })
  }
}