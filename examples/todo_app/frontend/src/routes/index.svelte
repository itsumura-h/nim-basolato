<script lang="ts">
  import {onMount} from 'svelte'
  import { replace } from 'svelte-spa-router';
  import {title, content} from '../stores/post'
  import Header from '../components/post/header.svelte'
  import Input from '../components/post/input.svelte'
  import Table from '../components/post/table.svelte'
  import PostUsecase from '../core/usecases/post_usecase';
  
  let isLogin: boolean
  let name: string
  let posts: Array<Object>
  let error:string

  const usecase = new PostUsecase

  onMount(async() => {
    isLogin = sessionStorage.getItem('isLogin') === 'true'
    if(!isLogin){
      replace('/signin')
    }

    getPosts()
  })

  const getPosts=async()=>{
    let data = await usecase.getPosts()
    name = data['name']
    posts = data['posts']
  }

  const storePost=async()=>{
    error = await usecase.storePost($title, $content)
    if(!error){
      getPosts()
      title.set('')
      content.set('')
    }
  }

  const changeStatus=async(id:number, status:boolean)=>{
    await usecase.changeStatus(id, status)
    getPosts()
  }

  const deletePost=async (id:number) => {
    await usecase.deletePost(id)
    getPosts()
  }

</script>

<main>
  <section class="section">
    <div class="container is-max-desktop">
      {#await posts}
        loading
      {:then posts}
        <Header name={name}/>
        <Input storePost={storePost}/>
        <Table posts={posts} changeStatus={changeStatus} deletePost={deletePost}/>
      {/await}

      {#await error}
        loading
      {:then error} 
        {#if error}
          {error}
        {/if}
      {/await}
    </div>
  </section>
</main>