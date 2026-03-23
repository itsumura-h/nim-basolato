type FeedType* = enum
  personal = "personal"
  tag = "tag"
  global = "global"


type HomeViewModel*  = object
  feedType*:FeedType
  tagName*:string
  hasPage*:bool
  page*:int

proc new*(_:type HomeViewModel, feedType="global", tagName="", hasPage=false, page=0): HomeViewModel =
  let feedType =
    if feedType == "personal":
      FeedType.personal
    elif feedType == "tag":
      FeedType.tag
    else:
      FeedType.global

  return HomeViewModel(
    feedType: feedType,
    tagName: tagName,
    hasPage: hasPage,
    page: page
  )
