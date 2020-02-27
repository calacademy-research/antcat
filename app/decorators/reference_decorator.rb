class ReferenceDecorator < Draper::Decorator
  delegate :sanitize, to: :helpers
  delegate :plain_text, :expandable_reference, :expanded_reference, to: :reference_formatter

  def link_to_reference
    helpers.link_to reference.keey, helpers.reference_path(reference)
  end

  def any_notes?
    [public_notes, editor_notes, taxonomic_notes].reject(&:blank?).any?
  end

  def public_notes
    format_italics sanitize reference.public_notes
  end

  def editor_notes
    format_italics sanitize reference.editor_notes
  end

  def taxonomic_notes
    format_italics sanitize reference.taxonomic_notes
  end

  def format_document_links
    [doi_link, pdf_link].reject(&:blank?).join(' ').html_safe
  end

  def doi_link
    return unless reference.doi?
    helpers.external_link_to reference.doi, ("https://doi.org/" + reference.doi)
  end

  def pdf_link
    return unless reference.downloadable?
    helpers.pdf_link_to 'PDF', reference.url
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
    format_italics helpers.add_period_if_necessary sanitize(reference.title)
  end

  private

    # TODO: See if what to do here. Added when extracting into `ReferenceFormatter`.
    def reference_formatter
      @reference_formatter ||= ReferenceFormatter.new(reference)
    end

    def format_italics string
      References::FormatItalics[string]
    end
end
