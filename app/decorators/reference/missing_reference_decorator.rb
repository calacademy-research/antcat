class MissingReferenceDecorator < ReferenceDecorator
  delegate_all

  def inline_citation
    make_html_safe reference.citation
  end

  def format_citation
    make_html_safe reference.citation
  end

  def key
    reference.citation
  end

  def format_reference_document_link; end

  def goto_reference_link target: nil; end
end
