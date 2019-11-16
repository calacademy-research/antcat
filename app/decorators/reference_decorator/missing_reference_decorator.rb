class MissingReferenceDecorator < ReferenceDecorator
  delegate :citation

  def format_document_links
  end

  private

    def format_citation
      sanitize citation
    end
end
