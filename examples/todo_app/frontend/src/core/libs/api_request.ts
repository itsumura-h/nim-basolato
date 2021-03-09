import axios from 'axios'

export class Response{
  ok:boolean
  data:object

  constructor(ok:boolean, data:object){
    this.ok = ok
    this.data = data
  }
}

interface IApiRequest{
  get(url:string):Promise<Response>
  post(url:string, params:object):Promise<Response>
  put(url:string, params:object):Promise<Response>
  delete(url:string):Promise<Response>
}

export class FetchRequest implements IApiRequest{
  fetch:any
  baseUrl:string

  constructor(obj:object){
    this.fetch = obj.fetch
    this.baseUrl = typeof window === 'undefined'? 'http://app:5000/api':'http://localhost:9000/api'
  }

  async get(url:string):Promise<Response>{
    url = this.baseUrl + url
    let res = await this.fetch(url, {credentials: 'include'})
    return new Response(res.ok, await res.json())
  }

  async post(url:string, params:object):Promise<Response>{
    url = this.baseUrl + url
    let res = await this.fetch(url, {
      method: 'POST',
      mode: 'cors',
      credentials: 'include',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(params)
    })
    return new Response(res.ok, await res.json())
  }

  async put(url:string, params:object):Promise<Response>{
    url = this.baseUrl + url
    let res = await this.fetch(url, {
      method: 'PUT',
      mode: 'cors',
      credentials: 'include',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(params)
    })
    return new Response(res.ok, await res.json())
  }

  async delete(url:string):Promise<Response>{
    url = this.baseUrl + url
    let res = await this.fetch(url, {
      method: 'DELETE',
      mode: 'cors',
      credentials: 'include',
      headers: {'Content-Type': 'application/json'},
    })
    return new Response(res.ok, await res.json())
  }
}

export class AxiosRequest implements IApiRequest{
  instance:any

  constructor(){
    this.instance = axios.create({
      withCredentials: true,
      baseURL: typeof window === 'undefined'? 'http://app:5000/api':'http://localhost:9000/api'
    })
  }
  
  async get(url:string):Promise<Response>{
    let res = await this.instance.get(url)
    return new Response(res.status == 200, res.data)
  }

  async post(url:string, params:object):Promise<Response>{
    let res = await this.instance.post(url, params)
    return new Response(res.status == 200, res.data)
  }

  async put(url:string, params:object):Promise<Response>{
    let res = await this.instance.put(url, params)
    return new Response(res.status == 200, res.data)
  }

  async delete(url:string):Promise<Response>{
    let res = await this.instance.delete(url)
    return new Response(res.status == 200, res.data)
  }
}