class UnknownReferenceDecorator < ReferenceDecorator
  delegate :citation

  private

    def format_citation
      make_html_safe citation
    end
end
