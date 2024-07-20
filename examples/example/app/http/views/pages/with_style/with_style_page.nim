import ../../../../../../../src/basolato/view
import ../../components/with_style/with_style_component1
import ../../components/with_style/with_style_component2
import ../../components/with_style/with_style_component3


proc withStylePage*():Component =
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
