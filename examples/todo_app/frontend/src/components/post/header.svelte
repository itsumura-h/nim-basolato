<script lang="ts">
  import SignUsecase from '../../core/usecases/sign_usecase'

  export let name: string

  const signout=()=>{
    let usecase = new SignUsecase
    usecase.signout()
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