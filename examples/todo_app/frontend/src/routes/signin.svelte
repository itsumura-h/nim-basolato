<script lang="ts">
  import { goto } from '@sapper/app'
  import SignRepository from '../core/repositories/sign_repository'
  import {onMount} from 'svelte'

  let repository = new SignRepository
  let email: string
  let password: string
  let isLogin: boolean
  let error: string

  onMount(()=>{
    isLogin = sessionStorage.getItem('isLogin') === 'true'
    if(isLogin){
      goto('/')
    }
  })

  const signin=async ()=>{
    let res = await repository.signin(email, password)
    console.log(res.data)
    if(res.ok){
      sessionStorage.setItem('isLogin', 'true')
      goto('/')
    }else{
      error = res.data.error
    }
  }
</script>


<style lang="scss">
  .errors {
    background-color: pink;
    color: red;
  }
</style>


<section class="section">
  <div class="container is-max-desktop">
    <div class="card">
      <div class="card-header">
        <div class="card-header-title"> Todo App Sign In</div>
      </div>
      <div class="card-content">
        {#if error && error.length > 0}
          <p class="errors field">{error}</p>
        {/if}
        <form method="POST">
          <div class="field">
            <p class="control has-icons-left">
              <input type="text" name="email" placeholder="email" bind:value={email} class="input" >
              <span class="icon is-small is-left">
                <i class="fas fa-envelope"></i>
              </span>
            </p>
          </div>

          <div class="field">
            <p class="control has-icons-left">
              <input type="password" name="password" placeholder="password" bind:value={password} class="input" >
              <span class="icon is-small is-left">
                <i class="fas fa-lock"></i>
              </span>
            </p>
          </div>

          <div class="field">
            <button on:click={signin} type="button" class="button is-primary is-light is-outlined">signin</button>
          </div>
        </form>
      </div>
      <a href="/signup">Sign up here</a>
    </div>
  </div>
</section>