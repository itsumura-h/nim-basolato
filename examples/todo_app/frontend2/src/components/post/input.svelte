<script lang="ts">
  import {title, content} from '../../stores/post'
  export let storePost:() => void
</script>


<style lang="scss">
  .form{
    padding: 10px 0px;
  }
</style>

<div class="container">
  <div method="POST" class="field form">
    <div class="field">
      <div class="controll">
        <input type="text" on:volumechange={title.set} bind:value={$title} name="title" placeholder="title" class="input">
      </div>
    </div>

    <div class="field">
      <div class="controll">
        <textarea name="content" on:volumechange={content.set} bind:value={$content} placeholder="content" class="textarea"></textarea>
      </div>
    </div>

    <div class="field">
      <div class="controll">
        <button type="button" on:click={storePost} class="button is-primary is-light is-outlined">add</button>
      </div>
    </div>
  </div>
</div>