class BookReferenceDecorator < ReferenceDecorator
  delegate :publisher, :pagination

  private
    def format_citation
      "#{h publisher.display_name}, #{h pagination}".html_safe
    end
end
