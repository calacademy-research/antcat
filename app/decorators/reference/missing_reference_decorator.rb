class MissingReferenceDecorator < ReferenceDecorator
  delegate_all

  def format_inline_citation options = {}
    make_html_safe reference.citation
  end

  def format_citation
    make_html_safe reference.citation
  end

end
