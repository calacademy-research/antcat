class NestedReferenceDecorator < ReferenceDecorator
  delegate :pages_in, :nesting_reference

  private
    def format_citation
      "#{h pages_in} #{nesting_reference.decorate.formatted}".html_safe
    end
end
