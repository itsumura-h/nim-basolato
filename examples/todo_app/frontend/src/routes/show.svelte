<script lang="ts">
  let title:string
  let content:string
  let isFinished:boolean

</script>

<style lang="scss">
  .form{
    padding: 10px 0px;
  }
</style>

<section class="section">
  <div class="container is-max-desktop">
    <a href="/">back</a>
    <div class="field form">
      <div class="field">
        <div class="controll">
          <input type="text" name="title" placeholder="title" class="input" bind:value={title}>
        </div>
      </div>
  
      <div class="field">
        <div class="controll">
          <textarea name="content" placeholder="content" class="textarea">{content}</textarea>
        </div>
      </div>
  
      <div class="field">
        <div class="select">
          <select name="is_finished">
            {#if isFinished}
              <option value="true" selected>Finished</option>
              <option value="false">Not finished</option>
            {:else}
              <option value="true">Finished</option>
              <option value="false" selected>Not finished</option>
            {/if}
          </select>
        </div>
      </div>
 
      <!-- errorView -->
  
      <div class="field">
        <div class="controll">
          <button type="submit" class="button is-primary is-light is-outlined">update</button>
        </div>
      </div>
    </div>
  
    <div>
      <div class="field">
        <div class="controll">
          <button type="button" class="button is-danger is-light is-outlined">delete</button>
        </div>
      </div>
    </div>
  
  </div>
</section>