# coding: UTF-8
class ReferenceKey
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def initialize reference
    @reference = reference
  end

  def to_taxt
    Taxt.encode_reference @reference
  end

  def to_s
    names = @reference.author_names.map &:last_name
    case
    when names.size == 1
      "#{names.first}, "
    when names.size == 2
      "#{names.first} & #{names.second}, "
    else
      string = names[0..-2].join ', '
      string << " & " << names[-1] << ', '
    end << @reference.short_citation_year
  end

  def to_link user
    content_tag(:span, :class => :reference_key_and_expansion) do
      content_tag(:a, to_s, :href => '#', :class => :reference_key) +
      content_tag(:span, :class => :reference_key_expansion) do
        content = content_tag(:span, ReferenceFormatter.format(@reference), class: :reference_key_expansion_text)
        document_link = CatalogFormatter.format_reference_document_link @reference, user
        content << document_link if document_link
        content << "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{@reference.id}\">".html_safe
        content << content_tag(:img, '', :src => "/images/external_link.png")
        content << "</a>".html_safe
        content.html_safe
      end
    end
  end

end
