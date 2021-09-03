<script lang="ts">
    import {goto} from '@sapper/app'
  import SignRepository from '../../core/repositories/sign_repository'

  export let name: string
  let repository = new SignRepository

  const signout=async()=>{
    sessionStorage.removeItem('isLogin')
    await repository.signout()
    goto('/signin')
  }
</script>

<style lang="scss">
  .right{
    float: right;
  }
</style>

<div class="container">
  <span>Login: {name}</span>
  <div class="right">
    <button on:click={signout} class="button is-info is-rounded">Logout</button>
  </div>
</div>