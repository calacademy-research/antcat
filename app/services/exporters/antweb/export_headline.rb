class Exporters::Antweb::ExportHeadline
  include ActionView::Helpers
  include ActionView::Context
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    content_tag :div do
      [
        headline_protonym,
        headline_type,
        type_fields,
        headline_notes,
        link_to_antcat,
        taxon.decorate.link_to_antwiki,
        taxon.decorate.link_to_hol
      ].compact.join(' ').html_safe
    end
  end

  private

    attr_reader :taxon

    delegate :headline_notes_taxt, to: :taxon

    def headline_protonym
      Exporters::Antweb::ExportHeadlineProtonym[taxon.protonym]
    end

    def headline_type
      TaxonDecorator::HeadlineType[taxon, for_antweb: true]
    end

    def type_fields
      Exporters::Antweb::TypeFields[taxon]
    end

    def headline_notes
      return if headline_notes_taxt.blank?
      TaxtPresenter[headline_notes_taxt].to_antweb
    end

    def link_to_antcat
      Exporters::Antweb::Exporter.antcat_taxon_link taxon
    end
end
