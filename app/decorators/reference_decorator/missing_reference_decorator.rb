class MissingReferenceDecorator < ReferenceDecorator
  delegate :citation

  def format_reference_document_link; end

  private

    def format_citation
      make_html_safe citation
    end
end
