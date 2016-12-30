class UnknownReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      format_italics helpers.add_period_if_necessary make_html_safe(reference.citation)
    end
end
