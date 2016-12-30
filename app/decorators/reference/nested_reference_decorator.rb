class NestedReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      citation = "#{h reference.pages_in} #{reference.nesting_reference.decorate.formatted}"
      format_italics citation.html_safe
    end
end
