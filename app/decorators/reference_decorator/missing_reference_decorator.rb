class MissingReferenceDecorator < ReferenceDecorator
  delegate :citation

  def format_reference_document_link
  end

  private

    def format_citation
      sanitize citation
    end
end
