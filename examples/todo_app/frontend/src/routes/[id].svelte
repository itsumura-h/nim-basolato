<script lang="ts" context="module">
  import PostRepository from '../core/repositories/post_repository'

  export async function preload({params}){
    const repository = new PostRepository(this)
    const response = await repository.getPost(params.id)
    return {
      id: params.id,
      title: response.ok? response.data.title: '',
      content: response.ok? response.data.content: '',
      isFinished: response.ok? response.data.isFinished: false
    }
  }
</script>

<script lang="ts">
  import {goto} from '@sapper/app'
  import Errors from '../components/errors.svelte'
  export let id
  export let title
  export let content
  export let isFinished
  let errors = []
  const repository = new PostRepository

  const update=async()=>{
    await repository.updatePost(id, title, content, isFinished)
    goto('/')
  }

  const deletePost=async()=>{
    await repository.deletePost(id)
    goto('/')
  }

</script>

<style lang="scss">
  .form{
    padding: 10px 0px;
  }
</style>

<section class="section">
  {#if errors.length == 0}
    <div class="container is-max-desktop">
      <a href="/">back</a>
      <div class="field form">
        <div class="field">
          <div class="controll">
            <input type="text" bind:value={title} placeholder="title" class="input">
          </div>
        </div>
    
        <div class="field">
          <div class="controll">
            <textarea bind:value={content} placeholder="content" class="textarea"></textarea>
          </div>
        </div>
    
        <div class="field">
          <div class="select">
            <select bind:value={isFinished}>
              <option value={true} selected={isFinished===true}>Finished</option>
              <option value={false} selected={isFinished===false}>Not finished</option>
            </select>
          </div>
        </div>

        <!-- errorView -->
        <Errors errors={errors}/>
    
        <div class="field">
          <div class="controll">
            <button type="button" on:click={update} class="button is-primary is-light is-outlined">update</button>
          </div>
        </div>
      </div>
    
      <div>
        <div class="field">
          <div class="controll">
            <button type="button" on:click={deletePost} class="button is-danger is-light is-outlined">delete</button>
          </div>
        </div>
      </div>
    
    </div>
  {:else}
    <Errors errors={errors}/>
    <div class="container is-max-desktop">
      <a href="/">back</a>
    </div>
  {/if}
</section>