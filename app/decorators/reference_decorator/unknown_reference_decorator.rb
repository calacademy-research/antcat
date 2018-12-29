class UnknownReferenceDecorator < ReferenceDecorator
  delegate :citation

  # NOTE: Not private like its siblings because we need it in a view.
  def format_citation
    make_html_safe citation
  end
end
