class MissingReferenceDecorator < ReferenceDecorator
  delegate_all

  def inline_citation
    make_html_safe reference.citation
  end

  def format_reference_document_link; end

  def link_to_reference; end

  private
    def format_citation
      make_html_safe reference.citation
    end
end
