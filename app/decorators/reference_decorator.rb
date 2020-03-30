# frozen_string_literal: true

class ReferenceDecorator < Draper::Decorator
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
    [doi_link, pdf_link].reject(&:blank?).join(' ').html_safe
  end

  def doi_link
    return unless reference.doi?
    h.external_link_to reference.doi, ("https://doi.org/" + reference.doi)
  end

  def pdf_link
    return unless reference.downloadable?
    h.pdf_link_to 'PDF', reference.routed_url
  end

  def format_review_state
    {
      "none"      => 'Not reviewed',
      "reviewed"  => 'Reviewed',
      "reviewing" => 'Being reviewed'
    }[reference.review_state]
  end

  # TODO: `sanitize(reference.title)` converts ampersands to "&amp;" (only an issue in `Exporters::TaxaAsTxt`).
  # Example: "Brandão &amp; Martins-Neto" from `Taxon.find(429023).authorship.reference.decorate.send(:format_title)`.
  def format_title
    format_italics h.add_period_if_necessary sanitize(reference.title)
  end

  private

    def reference_formatter
      @reference_formatter ||= References::CachedReferenceFormatter.new(reference)
    end

    def format_italics string
      References::FormatItalics[string]
    end
end
