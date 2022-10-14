# frozen_string_literal: true

class NestedReferenceDecorator < ReferenceDecorator
  delegate :nesting_reference

  # Fall back to nesting reference's PDF if nested does not have one.
  def pdf_link
    return nesting_reference_pdf_link unless reference.downloadable?
    h.external_link_to 'PDF', reference.routed_url
  end

  private

    def nesting_reference_pdf_link
      return unless nesting_reference.downloadable?
      h.external_link_to 'PDF', nesting_reference.routed_url
    end
end
