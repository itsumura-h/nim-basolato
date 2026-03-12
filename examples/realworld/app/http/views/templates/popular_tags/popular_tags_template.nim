import std/asyncdispatch
import basolato/view
import ./popular_tags_template_model
import ../../../../presenters/popular_tag/popular_tag_presenter


proc popularTagsTemplate*():Future[Component] {.async.} =
  let presenter = PopularTagListPresenter.new()
  let model = presenter.invoke().await

  tmpl"""
    <div class="sidebar">
      <p>Popular Tags</p>

      <div class="tag-list">
        $for tag in model.tagList{
          <a href="/tag/$(tag.id)" class="tag-pill tag-default">$(tag.name)</a>
        }
      </div>
    </div>
  """
