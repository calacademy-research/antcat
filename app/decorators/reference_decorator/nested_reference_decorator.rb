class NestedReferenceDecorator < ReferenceDecorator
  delegate :pages_in, :nesting_reference

  private

    def format_citation
      "#{h pages_in} #{nesting_reference.decorate.plain_text}".html_safe
    end

    # Fall back to nesting reference's PDF is nestee does not have one.
    def pdf_link
      return nesting_reference_pdf_link unless reference.downloadable?
      helpers.external_link_to 'PDF', reference.url
    end

    def nesting_reference_pdf_link
      return unless nesting_reference.downloadable?
      helpers.external_link_to 'PDF', nesting_reference.url
    end
end
