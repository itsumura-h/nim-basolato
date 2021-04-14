<script lang="ts">
  import {onMount} from 'svelte'
  import {goto} from '@sapper/app'
  import {title, content} from '../stores/post'
  import Error from '../components/errors.svelte'
  import Header from '../components/post/Header.svelte'
  import Input from '../components/post/Input.svelte'
  import Table from '../components/post/Table.svelte'
  import PostRepository from '../core/repositories/post_repository'
import { compute_slots } from 'svelte/internal';
  
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
    let res = await repository.storePost($title, $content)
    if(res.ok){
      getPosts()
      title.set('')
      content.set('')
    }else{
      error = res.data.error
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
        {#if error}
          <Error errors={[error]} />
        {/if}
        <Table posts={posts} changeStatus={changeStatus} deletePost={deletePost}/>
      {/await}
    </div>
  </section>
</main>