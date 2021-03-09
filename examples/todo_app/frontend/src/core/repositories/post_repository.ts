import {Response, FetchRequest, AxiosRequest} from '../libs/api_request'

export default class PostRepository{
  request: IApiRequest

  constructor(obj?:object){
    this.request = typeof obj === "undefined"? new AxiosRequest: new FetchRequest(obj)
  }

  async getPost(id:number):Response{
    const url = `/posts/${id}`
    let res = await this.request.get(url)
    return res
  }

  async getPosts():Response{
    const url = '/posts'
    let res = await this.request.get(url)
    return res
  }

  async storePost(title:string, content:string){
    const params = {
      title:title,
      content:content
    }
    const url = '/posts'
    await this.request.post(url, params)
  }

  async updatePost(id:number, title:string, content:string, isFinished:boolean):boolean{
    const params = {
      title:title,
      content:content,
      isFinished:isFinished
    }
    const url = `/posts/${id}`
    let res = await this.request.put(url, params)
    return res.ok
  }

  async changeStatus(id:number, status:boolean){
    let params = {
      status: status
    }
    await this.request.put(`/change-status/${id}`, params)
  }

  async deletePost(id:number){
    return await this.request.delete(`/posts/${id}`)
  }
}