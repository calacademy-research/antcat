class Exporters::Antweb::InlineCitation
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  include Service

  def initialize reference
    @reference = reference
  end

  def call
    [reference_link, document_links].reject(&:blank?).join(' ').html_safe
  end

  private

    attr_reader :reference

    def reference_link
      link_to reference.keey.html_safe, reference_url, title: unitalicize(plain_text)
    end

    def document_links
      reference.decorate.format_reference_document_link
    end

    # Hardcoded, or we must set `host` + use `reference_url(reference)`.
    def reference_url
      "http://antcat.org/references/#{reference.id}"
    end

    def plain_text
      reference.decorate.plain_text
    end
end
