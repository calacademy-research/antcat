class BookReferenceDecorator < ReferenceDecorator
  delegate :publisher, :pagination

  private

    def format_citation
      sanitize "#{publisher.display_name}, #{pagination}"
    end
end
