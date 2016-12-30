class BookReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      citation = "#{h reference.publisher}, #{h reference.pagination}"
      format_italics helpers.add_period_if_necessary citation.html_safe
    end
end
