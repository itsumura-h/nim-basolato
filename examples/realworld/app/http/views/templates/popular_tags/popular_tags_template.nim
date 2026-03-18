import basolato/view
import ./popular_tags_template_model


proc popularTagsTemplate*(model: PopularTagsTemplateModel): Component =
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
