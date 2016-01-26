class MissingReferenceDecorator < ReferenceDecorator
  delegate_all

  def format_inline_citation options = {}
    make_html_safe reference.citation
  end

  def format_citation
    make_html_safe reference.citation
  end

  def to_link _options = nil
    citation.html_safe
  end

  def to_s
    reference.citation
  end

  def format_reference_document_link; end

  def goto_reference_link; end

end
