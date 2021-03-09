import axios from 'axios'
import Request from '../libs/api'

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
    const req = Request(this)
    const res = await req.get('/posts')
    return await res.data
  }

  async getPost(id:number):Promise<ApiResponse>{
    const req = Request(this)
    try{
      let res = await req.get(`/posts/${id}`)
      let obj = {
        errors: [],
        data: res.data
      } 
      return new ApiResponse(obj)  
    }catch(err){
      console.error(err)
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

  async changeStatus(id:number, status:boolean){
    let params = {
      status: status
    }
    return request.put('/change-status/' + id, params)
  }

  async deletePost(id:number){
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