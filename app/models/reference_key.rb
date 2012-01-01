# coding: UTF-8
class ReferenceKey
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def initialize reference
    @reference = reference
  end

  def to_taxt
    Taxt.reference self
  end

  def to_link user
    key = @reference.author_names.first.last_name + ', ' + @reference.citation_year
    content_tag(:span, :class => :reference_key_and_expansion) do
      content_tag(:a, key, :href => '#', :class => :reference_key) +
      content_tag(:span, :class => :reference_key_expansion) do
        content = content_tag(:span, ReferenceFormatter.format(@reference), :class => :reference_key_expansion_text)
        document_link = CatalogFormatter.format_reference_document_link(@reference, user)
        content << document_link.html_safe if document_link
        content << "<a class=\"goto_reference_link\" target=\"_blank\" href=\"/references?q=#{@reference.id}\">".html_safe
        content << content_tag(:img, '', :src => "/images/external_link.png").html_safe
        content << "</a>".html_safe
        content.html_safe
      end
    end.html_safe
  end

end
