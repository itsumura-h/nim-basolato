import axios, { AxiosResponse } from 'axios'
import request from '../libs/request'

export default class PostUsecase {
  async getPosts(){
    return request.get('/posts')
    .then(response=>{
      return response.data
    })
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

  async changeStatus(id:number, status:boolean):Promise<AxiosResponse<Any>{
    let params = {
      status: status
    }
    return request.put('/change-status/' + id, params)
  }

  async deletePost(id:number):Promise<AxiosResponse<Any>{
    return request.delete('/posts/' + id)
  }
}