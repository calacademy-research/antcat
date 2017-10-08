module MarkdownHelper
  P_HTML_ELEMENT_REGEX = /\A<p>(.*)<\/p>\Z/m

  def markdown content, no_wrappring_p: false
    return '' unless content

    rendered = Markdowns::Render[content]
    return strip_wrapping_p(rendered).html_safe if no_wrappring_p
    rendered
  end

  def antcat_markdown_only content
    Markdowns::ParseAntcatHooks[content]
  end

  private
    def strip_wrapping_p rendered
      Regexp.new(P_HTML_ELEMENT_REGEX).match(rendered)[1] rescue rendered
    end
end
