import ../../../../../../../src/basolato/view
import ../../components/with_style/with_style_component1
import ../../components/with_style/with_style_component2
import ../../components/with_style/with_style_component3
import ../../presenters/with_style/with_style_page_viewmodel


proc withStyleTemplate*(vm: WithStylePageViewModel): Component


proc withStylePage*():Component =
  let vm = WithStylePageViewModel.new()
  return withStyleTemplate(vm)


proc withStyleTemplate*(vm: WithStylePageViewModel): Component =
  tmpl"""
    <main>
      <article>
        <a href="/">go back</a>
        $(withStyleComponent1())
        $(withStyleComponent2())
        $(withStyleComponent3())
      </article>
    </main>
  """
