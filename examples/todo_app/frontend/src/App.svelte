<script lang="ts">
	import Router from 'svelte-spa-router' // svelte-spa-routerをインポートする
	import Signin from './routes/signin.svelte'
	import Index from './routes/index.svelte'

	const routes = {
		'/': Index,
		'/signin': Signin,
	}
</script>

<main>
	<Router {routes}/>
</main>
