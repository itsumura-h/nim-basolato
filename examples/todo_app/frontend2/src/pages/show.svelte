<script lang="ts">
  import {onMount} from 'svelte'
  import { navigate } from 'svelte-routing'
  import Errors from '../components/errors.svelte'
  import {PostUsecase} from '../core/usecases/post_usecase'
  export let params
  let res
  let title:string
  let content:string
  let isFinished:boolean
  let errors = []

  let usecase = new PostUsecase
  onMount(async()=>{
    console.log(params)

    res = await usecase.getPost(params.id)
    if(res.hasError()){
      errors = res.errors
    }else{
      title = res.data['title']
      content = res.data['content']
      isFinished = res.data['isFinished']
    }
  })

  const update=async()=>{
    await usecase.updatePost(id, title, content, isFinished)
    navigate('/')
  }

  const deletePost=async()=>{
    console.log('=== deletePost')
    console.log(id)
    // await usecase.deletePost(id)
    // $goto('/')
  }

</script>

<style lang="scss">
  .form{
    padding: 10px 0px;
  }
</style>

<section class="section">
  {#await res}
    ..loading
  {:then res} 
    {#if errors.length == 0}
      <div class="container is-max-desktop">
        <a href={$url('./index')}>back</a>
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
              <button type="button" on:click={deletePost} class="button is-danger is-light is-outlined">delete111</button>
            </div>
          </div>
        </div>
      
      </div>
    {:else}
      <Errors errors={errors}/>
      <div class="container is-max-desktop">
        <a href={$url('/')}>back</a>
      </div>
    {/if}
  {/await}
</section>