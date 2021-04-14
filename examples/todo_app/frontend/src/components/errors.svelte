<script lang="ts">
  export let errors = []
</script>

<style lang="scss">
  .errors{
    background-color: pink;
    color: red;
  }
</style>

<div class="field">
  {#if errors.length > 0}
    <div class="container errors">
      {#each errors as error}
        <p class="content">{error}</p>
      {/each}
    </div>
  {/if}
</div>