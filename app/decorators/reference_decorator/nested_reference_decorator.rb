class NestedReferenceDecorator < ReferenceDecorator
  delegate :pages_in, :nesting_reference

  private
    def format_citation
      "#{h pages_in} #{nesting_reference.decorate.formatted}".html_safe
    end

    # Fall back to nesting reference's PDF is nestee does not have one.
    def pdf_link
      super unless reference.downloadable?
      helpers.link_to 'PDF', reference.url
    end
end
