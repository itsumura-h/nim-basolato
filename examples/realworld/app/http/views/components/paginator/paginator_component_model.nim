import std/math
import ../../../../../config/consts

type PaginatorComponentModel* = object
  hasPages*:bool
  currentPage*: int
  lastPage*: int
  path*: string

proc new*(_:type PaginatorComponentModel, currentPage:int, total:int, path:string): PaginatorComponentModel =
  let hasPages = total > FEED_DISPLAY_COUNT
  let lastPage = (total / FEED_DISPLAY_COUNT).ceil().toInt()
  return PaginatorComponentModel(hasPages: hasPages, currentPage: currentPage, lastPage: lastPage, path: path)
