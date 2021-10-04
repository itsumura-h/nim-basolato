import { Response, IApiRequest, initRequest } from '../libs/api_request'


export default class SignRepository {
  request: IApiRequest

  constructor(obj?: object) {
    this.request = initRequest(obj)
  }

  async signin(email, password: string): Promise<Response> {
    let params = {
      email: email,
      password: password
    }
    return await this.request.post("/signin", params)
  }

  async signout() {
    await this.request.delete('/signout')
  }
}