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
    content_tag(:span, :class => :reference_key_and_expansion) do
      content_tag(:a, key, :href => '#', :class => :reference_key) +
      content_tag(:span, :class => :reference_key_expansion) do
        content_tag(:span, ReferenceFormatter.format(@reference), :class => :reference_key_expansion_text) +
        ("<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{@reference.id}\">" +
          content_tag(:img, '', :src => "/images/external_link.png") +
        "</a>").html_safe
      end
    end.html_safe
  end

end
