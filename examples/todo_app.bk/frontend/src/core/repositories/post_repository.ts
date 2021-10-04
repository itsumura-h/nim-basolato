import { Response, IApiRequest, initRequest } from '../libs/api_request'

export default class PostRepository {
  request: IApiRequest

  constructor(obj?: object) {
    this.request = initRequest(obj)
  }

  async getPost(id: number): Promise<Response> {
    const url = `/posts/${id}`
    return await this.request.get(url)
  }

  async getPosts(): Promise<Response> {
    const url = '/posts'
    return await this.request.get(url)
  }

  async storePost(title: string, content: string): Promise<Response> {
    const params = {
      title: title,
      content: content
    }
    const url = '/posts'
    return await this.request.post(url, params)
  }

  async updatePost(id: number, title: string, content: string, isFinished: boolean): Promise<Response> {
    const params = {
      title: title,
      content: content,
      isFinished: isFinished
    }
    const url = `/posts/${id}`
    return await this.request.put(url, params)
  }

  async changeStatus(id: number, status: boolean) {
    let params = {
      status: status
    }
    await this.request.put(`/change-status/${id}`, params)
  }

  async deletePost(id: number) {
    await this.request.delete(`/posts/${id}`)
  }
}