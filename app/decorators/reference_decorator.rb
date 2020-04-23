# frozen_string_literal: true

class ReferenceDecorator < Draper::Decorator
  DOI_BASE_URL = "https://doi.org/"
  FORMATTED_REVIEW_STATES = {
    Reference::REVIEW_STATE_NONE      => 'Not reviewed',
    Reference::REVIEW_STATE_REVIEWED  => 'Reviewed',
    Reference::REVIEW_STATE_REVIEWING => 'Being reviewed'
  }

  delegate :sanitize, to: :helpers
  delegate :plain_text, :expandable_reference, :expanded_reference, to: :reference_formatter

  def link_to_reference
    h.link_to reference.keey, h.reference_path(reference)
  end

  def format_public_notes
    format_italics sanitize reference.public_notes
  end

  def format_editor_notes
    format_italics sanitize reference.editor_notes
  end

  def format_taxonomic_notes
    format_italics sanitize reference.taxonomic_notes
  end

  def format_document_links
    h.safe_join [doi_link, pdf_link].reject(&:blank?), ' '
  end

  def doi_link
    return unless reference.doi?
    h.external_link_to reference.doi, (DOI_BASE_URL + reference.doi)
  end

  def pdf_link
    return unless reference.downloadable?
    h.pdf_link_to 'PDF', reference.routed_url
  end

  def format_review_state
    FORMATTED_REVIEW_STATES[reference.review_state]
  end

  # TODO: `sanitize(reference.title)` converts ampersands to "&amp;" (only an issue in `Exporters::TaxaAsTxt`).
  # Example: "Brandão &amp; Martins-Neto" from `Taxon.find(429023).authorship.reference.decorate.send(:format_title)`.
  def format_title
    format_italics h.add_period_if_necessary sanitize(reference.title)
  end

  def described_taxa
    Taxon.joins(protonym: { authorship: :reference }).where(references: { id: reference.id })
  end

  private

    def reference_formatter
      @_reference_formatter ||= References::CachedReferenceFormatter.new(reference)
    end

    def format_italics string
      References::FormatItalics[string]
    end
end
