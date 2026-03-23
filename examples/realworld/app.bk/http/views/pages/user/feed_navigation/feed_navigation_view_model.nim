type UserFeedNavbar*  = object
  title*:string
  isActive*:bool
  url*:string
  hxGetUrl*:string

proc new*(_:type UserFeedNavbar, title:string, isActive:bool, url:string, hxGetUrl:string):UserFeedNavbar =
  return UserFeedNavbar(
    title:title,
    isActive:isActive,
    url:url,
    hxGetUrl:hxGetUrl,
  )


type FeedNavigationViewModel*  = object
  feedNavbarItems*:seq[UserFeedNavbar]

proc new*(_:type FeedNavigationViewModel, feedNavbarItems:seq[UserFeedNavbar]):FeedNavigationViewModel =
  return FeedNavigationViewModel(
    feedNavbarItems:feedNavbarItems
  )
