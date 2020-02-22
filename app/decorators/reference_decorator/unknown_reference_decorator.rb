class UnknownReferenceDecorator < ReferenceDecorator
  delegate :citation

  private

    def format_citation
      sanitize citation
    end
end
