<script lang="ts">
  import {onMount} from 'svelte'
  import { replace } from 'svelte-spa-router';
  import SignUsecase from '../core/usecases/sign_usecase'
  
  let isLogin: boolean

  onMount(() => {
    isLogin = sessionStorage.getItem('isLogin') === 'true'
    if(!isLogin){
      replace('/signin')
    }
  })

  let usecase = new SignUsecase
  let data = usecase.dataFetch()
</script>

<main>
  <h1>index</h1>
  {#await data}
    ..loading
  {:then data}
    {data}
  {/await}
</main>