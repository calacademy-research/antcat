class UnknownReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      make_html_safe reference.citation
    end
end
