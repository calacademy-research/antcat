class MissingReferenceDecorator < ReferenceDecorator
  delegate_all

  def format_inline_citation _options = {}
    make_html_safe reference.citation
  end

  def format_citation
    make_html_safe reference.citation
  end

  def to_link _options = nil
    citation.html_safe
  end

  def key
    reference.citation
  end

  def format_reference_document_link; end

  def goto_reference_link target: nil; end
end
