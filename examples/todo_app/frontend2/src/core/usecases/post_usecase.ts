import axios, {AxiosResponse} from 'axios'
import request from '../libs/request'

export class ApiResponse {
  errors:Array<string>
  data?:object

  constructor(init?: Partial<ApiResponse>) {
    Object.assign(this, init);
  }

  hasError(){
    return this.errors.length > 0
  }
}

export class PostUsecase {
  async getPosts(){
    const res = await request.get('/posts')
    return await res.data
  }

  async getPost(id:number):Promise<ApiResponse>{
    try{
      let res = await request.get(`/posts/${id}`)
      let obj = {
        errors: [],
        data: res.data
      } 
      return new ApiResponse(obj)  
    }catch(err){
      let obj = {
        errors: err.response.data.errors,
        data:null
      }
      return new ApiResponse(obj)
    }
  }

  async storePost(title:string, content:string){
    let params = {
      title:title,
      content:content
    }
    return request.post('/posts', params)
    .then(response=>{
      //
    })
    .catch(err=>{
      return err.response.data.error
    })
  }

  async changeStatus(id:number, status:boolean):Promise<AxiosResponse<any>>{
    let params = {
      status: status
    }
    return request.put('/change-status/' + id, params)
  }

  async deletePost(id:number):Promise<AxiosResponse<any>>{
    return request.delete('/posts/' + id)
  }

  async updatePost(id:number, title:string, content:string, isFinished:boolean):Promise<boolean>{
    let params = {
      title:title,
      content:content,
      isFinished:isFinished
    }
    return await request.put('/posts/'+id, params)
    .then(response=>{
      return true
    })
    .catch(err=>{
      return false
    })
  }
}