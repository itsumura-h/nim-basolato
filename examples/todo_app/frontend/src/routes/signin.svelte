<script lang="ts">
  import SignUsecase from '../core/usecases/sign_usecase'

  let email: string
  let password: string

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
