<script lang="ts">
  import {onMount} from 'svelte'
  import {goto} from '@sapper/app'
  import {title, content} from '../stores/post'
  import Header from '../components/post/Header.svelte'
  import Input from '../components/post/Input.svelte'
  import Table from '../components/post/Table.svelte'
  import PostRepository from '../core/repositories/post_repository'
  
  let isLogin: boolean
  let name: string
  let posts: Array<Object>
  let error:string

  const repository = new PostRepository

  onMount(async() => {
    isLogin = sessionStorage.getItem('isLogin') === 'true'
    if(!isLogin){
      goto('/signin')
    }

    getPosts()
  })

  const getPosts=async()=>{
    let res = await repository.getPosts()
    name = res.data.name
    posts = res.data.posts
  }

  const storePost=async()=>{
    error = await repository.storePost($title, $content)
    if(!error){
      getPosts()
      title.set('')
      content.set('')
    }
  }

  const changeStatus=async(id:number, status:boolean)=>{
    await repository.changeStatus(id, status)
    getPosts()
  }

  const deletePost=async(id:number) => {
    await repository.deletePost(id)
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
        <!-- {#await error}
        {:then error} 
          {#if error}
            {error}
          {/if}
        {/await} -->
        <Table posts={posts} changeStatus={changeStatus} deletePost={deletePost}/>
      {/await}
    </div>
  </section>
</main>