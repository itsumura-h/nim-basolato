import { writable } from 'svelte/store';

const createTitle=()=>{
  const { subscribe, set, update } = writable('')

  return {
    subscribe,
    set:val=>set(val),
  }
}
export const title = createTitle()

const createContent=()=>{
  const { subscribe, set, update } = writable('')
  return {
    subscribe,
    set:val=>set(val),
  }
}
export const content = createContent()