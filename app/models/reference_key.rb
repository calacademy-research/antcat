# coding: UTF-8
class ReferenceKey
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def initialize reference
    @reference = reference
  end

  def to_text
    "<ref #{@reference.id}>"
  end

  def to_link
    key = @reference.author_names.first.last_name + ', ' + @reference.citation_year
    content_tag(:span) do
      content_tag(:a, key, href: "#", class: :reference_key).html_safe +
      content_tag(:a, ReferenceFormatter.format(@reference), href: "#", class: :reference_key_expansion).html_safe
    end.html_safe
  end

end
