# coding: UTF-8
class ReferenceKey
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include Formatters::Formatter

  def initialize reference
    @reference = reference
  end

  def to_taxt
    Taxt.encode_reference @reference
  end

  def to_s
    return '' unless @reference.id
    names = @reference.author_names.map &:last_name
    case
    when names.size == 0
      '[no authors]'
    when names.size == 1
      "#{names.first}"
    when names.size == 2
      "#{names.first} & #{names.second}"
    else
      string = names[0..-2].join ', '
      string << " & " << names[-1]
    end << ', ' << @reference.short_citation_year
  end

  def to_link user, options = {}
    options = options.reverse_merge expansion: true
    reference_key_string = to_s
    reference_string = Formatters::ReferenceFormatter.format @reference
    if options[:expansion]
      to_link_with_expansion reference_key_string, reference_string, user
    else
      to_link_without_expansion reference_key_string, reference_string, user
    end
  end

  def to_link_with_expansion reference_key_string, reference_string, user
    content_tag :span, class: :reference_key_and_expansion do
      content = ''.html_safe
      content << Formatters::LinkFormatter.link(reference_key_string, '#', title: make_to_link_title(reference_string), class: :reference_key, target: nil)
      content << content_tag(:span, class: :reference_key_expansion) do
        inner_content = ''.html_safe
        inner_content << reference_key_expansion_text(reference_string, reference_key_string)
        inner_content << document_link(user)
        inner_content << goto_reference_link
        inner_content
      end
      content
    end
  end

  def to_link_without_expansion reference_key_string, reference_string, user
    url = "http://antcat.org/references?q=#{@reference.id}"
    content = Formatters::LinkFormatter.link reference_key_string, url, title: make_to_link_title(reference_string)
    content << document_link(user)
    content
  end

  def make_to_link_title string
    unitalicize string
  end

  def reference_key_expansion_text reference_string, reference_key_string
    content = content_tag :span, reference_string, title: reference_key_string, class: :reference_key_expansion_text
  end

  def document_link user
    string = Formatters::CatalogFormatter.format_reference_document_link @reference, user
    return '' unless string
    ' '.html_safe + string
  end

  def goto_reference_link
    Formatters::LinkFormatter.link image_tag('external_link.png'), "/references?q=#{@reference.id}", class: :goto_reference_link
  end

end
