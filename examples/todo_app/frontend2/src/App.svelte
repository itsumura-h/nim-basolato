<script lang="ts">
	import { Route, links } from 'svelte-routing'
	import Index from './pages/index.svelte'
	import Show from './pages/show.svelte'
	import Signin from './pages/signin.svelte'

	const routes = [
		{path: '/', component: Index},
		{path: '/:id', component: Show},
		{path: '/signin', component: Signin},
	]
</script>

<main use:links>
	{#each routes as route}
		<Route path={route.path} component={route.component} let:params/>
	{/each}
</main>
