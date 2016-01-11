class ReferenceKey
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper

  def initialize reference
    @reference = reference
  end

  def to_taxt
    raise "is this used outside specs?"
    Taxt.encode_reference @reference
  end

  def to_s
    return '' unless @reference.id
    names = @reference.decorate.format_author_last_names
  end

  def to_link user, options = {}
    options = options.reverse_merge expansion: true
    reference_key_string = to_s
    reference_string = @reference.decorate.format
    if options[:expansion]
      to_link_with_expansion reference_key_string, reference_string
    else
      to_link_without_expansion reference_key_string, reference_string
    end
  end

  def document_link
    @reference.decorate.format_reference_document_link
  end

  def goto_reference_link
    @reference.decorate.goto_reference_link
  end

  private
    def to_link_with_expansion reference_key_string, reference_string
      content_tag :span, class: :reference_key_and_expansion do
        content = link reference_key_string, '#',
                       title: make_to_link_title(reference_string),
                       class: :reference_key

        content << content_tag(:span, class: :reference_key_expansion) do
          inner_content = []
          inner_content << reference_key_expansion_text(reference_string, reference_key_string)
          inner_content << document_link
          inner_content << @reference.decorate.goto_reference_link
          inner_content.reject(&:blank?).join(' ').html_safe
        end
      end
    end

    def to_link_without_expansion reference_key_string, reference_string
      content = []
      content << link(reference_key_string,
                      "http://antcat.org/references/#{@reference.id}",
                      title: make_to_link_title(reference_string),
                      target: '_blank')
      content << document_link
      content.reject(&:blank?).join(' ').html_safe
    end

    def make_to_link_title string
      unitalicize string
    end

    def reference_key_expansion_text reference_string, reference_key_string
      content_tag :span, reference_string,
        class: :reference_key_expansion_text,
        title: reference_key_string
    end
end
