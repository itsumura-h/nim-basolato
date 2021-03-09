import axios from 'axios'

export class Response {
  ok: boolean
  status: number
  data: object

  constructor(ok: boolean, status: number, data: object) {
    this.ok = ok
    this.status = status
    this.data = data
  }
}

export interface IApiRequest {
  get(url: string): Promise<Response>
  post(url: string, params: object): Promise<Response>
  put(url: string, params: object): Promise<Response>
  delete(url: string): Promise<Response>
}

class FetchRequest implements IApiRequest {
  fetch: any
  baseUrl: string

  constructor(obj: object) {
    this.fetch = obj.fetch
    this.baseUrl = typeof window === 'undefined' ? 'http://app:5000/api' : 'http://localhost:9000/api'
  }

  async get(url: string): Promise<Response> {
    url = this.baseUrl + url
    return this.fetch(url, { credentials: 'include' })
      .then(async (result) => {
        return new Response(result.ok, result.status, await result.json())
      }).catch(async (err) => {
        return new Response(false, 400, await err.response.json())
      })
  }

  async post(url: string, params: object): Promise<Response> {
    url = this.baseUrl + url
    return this.fetch(url, {
      method: 'POST',
      mode: 'cors',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params)
    })
      .then(async (result) => {
        return new Response(result.ok, result.status, await result.json())
      }).catch(async (err) => {
        return new Response(false, err.response.status, await err.response.json())
      })
  }

  async put(url: string, params: object): Promise<Response> {
    url = this.baseUrl + url
    return this.fetch(url, {
      method: 'PUT',
      mode: 'cors',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params)
    })
      .then(async (result) => {
        return new Response(result.ok, result.status, await result.json())
      }).catch(async (err) => {
        return new Response(false, err.response.status, await err.response.json())
      })
  }

  async delete(url: string): Promise<Response> {
    url = this.baseUrl + url
    return this.fetch(url, {
      method: 'DELETE',
      mode: 'cors',
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' },
    })
      .then(async (result) => {
        return new Response(result.ok, result.status, await result.json())
      }).catch(async (err) => {
        return new Response(false, err.response.status, await err.response.json())
      })
  }
}

class AxiosRequest implements IApiRequest {
  instance: any

  constructor() {
    this.instance = axios.create({
      withCredentials: true,
      baseURL: typeof window === 'undefined' ? 'http://app:5000/api' : 'http://localhost:9000/api'
    })
  }

  async get(url: string): Promise<Response> {
    return this.instance.get(url)
      .then((result) => {
        return new Response(true, result.status, result.data)
      }).catch((err) => {
        return new Response(false, err.response.status, err.response.data)
      })
  }

  async post(url: string, params: object): Promise<Response> {
    return this.instance.post(url, params)
      .then((result) => {
        return new Response(true, result.status, result.data)
      }).catch((err) => {
        return new Response(false, err.response.status, err.response.data)
      })
  }

  async put(url: string, params: object): Promise<Response> {
    return this.instance.put(url, params)
      .then((result) => {
        return new Response(true, result.status, result.data)
      }).catch((err) => {
        return new Response(false, err.response.status, err.response.data)
      })
  }

  async delete(url: string): Promise<Response> {
    return this.instance.delete(url)
      .then((result) => {
        return new Response(true, result.status, result.data)
      }).catch((err) => {
        return new Response(false, err.response.status, err.response.data)
      })
  }
}

export const initRequest = (obj: object): AxiosRequest | FetchRequest => {
  return typeof obj === "undefined" ? new AxiosRequest : new FetchRequest(obj)
}