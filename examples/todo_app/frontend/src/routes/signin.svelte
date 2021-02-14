<script lang="ts">
  import {replace} from 'svelte-spa-router'
  import SignUsecase from '../core/usecases/sign_usecase'
  import {onMount} from 'svelte'

  let email: string
  let password: string
  let isLogin: boolean

  onMount(()=>{
    isLogin = sessionStorage.getItem('isLogin') === 'true'
    if(isLogin){
      replace('/')
    }
  })  

  const signin=()=>{
    const usecase = new SignUsecase
    usecase.signin(email, password)
  }
</script>

<main>
  <p><input bind:value={email} type="text" placeholder="email"></p>
  <p><input bind:value={password} type="password" placeholder="password"></p>
  <p><button type="button" on:click={signin}>sign in</button></p>
</main>
