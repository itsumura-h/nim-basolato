type FeedNavbarViewModel*  = object
  title*:string
  isActive*:bool
  hxGetUrl*:string
  hxPushUrl*:string

proc new*(_:type FeedNavbarViewModel,
  title:string,
  isActive:bool,
  hxGetUrl:string,
  hxPushUrl:string
):FeedNavbarViewModel =
  return FeedNavbarViewModel(
    title:title,
    isActive:isActive,
    hxGetUrl:hxGetUrl,
    hxPushUrl:hxPushUrl
  )
