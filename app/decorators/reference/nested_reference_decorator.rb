class NestedReferenceDecorator < ReferenceDecorator
  delegate_all

  def format_citation
    citation = "#{h reference.pages_in} #{reference.nesting_reference.decorate.format}"
    format_italics citation.html_safe
  end

end
