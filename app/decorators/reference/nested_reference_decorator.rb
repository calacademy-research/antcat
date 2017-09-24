class NestedReferenceDecorator < ReferenceDecorator
  delegate_all

  private
    def format_citation
      "#{h reference.pages_in} #{reference.nesting_reference.decorate.formatted}".html_safe
    end
end
