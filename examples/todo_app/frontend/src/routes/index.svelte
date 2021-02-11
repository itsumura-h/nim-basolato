<script lang="ts">
  import SignUsecase from '../core/usecases/sign_usecase'
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