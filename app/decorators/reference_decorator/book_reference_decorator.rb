class BookReferenceDecorator < ReferenceDecorator
  delegate :publisher, :pagination

  private
    def format_citation
      "#{h publisher}, #{h pagination}".html_safe
    end
end
