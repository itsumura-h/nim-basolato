import basolato/view
import ./island_tag_list_view_model


proc impl(popularTags:IslandTagListViewModel):Component =
  tmpl"""
    <div id="popular-tag-list" class="tag-list">
      $for tag in popularTags.tags{
        <a
          class="tag-pill tag-default"
          href="/tag-feed/$(tag.id)"
          hx-push-url="/tag-feed/$(tag.name)"
          hx-get="/island/home/tag-feed/$(tag.name)"
          hx-target="#feed-article-preview"
        >
          $(tag.name)
        </a>
      }
    </div>
  """

proc islandTagListView*(popularTags:IslandTagListViewModel):Component =
  return impl(popularTags)
