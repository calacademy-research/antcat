class BookReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      "#{h reference.publisher}, #{h reference.pagination}".html_safe
    end
end
