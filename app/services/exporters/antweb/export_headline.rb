class Exporters::Antweb::ExportHeadline
  include ActionView::Helpers
  include ActionView::Context
  include Service
  include LinkHelper

  def initialize taxon
    @taxon = taxon
  end

  def call
    content_tag :div, class: 'headline' do
      notes = headline_notes
      hol_link = link_to_hol(@taxon)
      string = headline_protonym
      string << ' ' << headline_type
      string << ' ' << notes if notes
      string << ' ' << link_to_antcat if link_to_antcat
      string << ' ' << link_to_antwiki(@taxon) if link_to_antwiki(@taxon)
      string << ' ' << hol_link if hol_link
      string
    end
  end

  private
    def headline_protonym
      TaxonDecorator::HeadlineProtonym[@taxon, for_antweb: true]
    end

    def headline_type
      TaxonDecorator::HeadlineType[@taxon, for_antweb: true]
    end

    def headline_notes
      return unless @taxon.headline_notes_taxt.present?
      TaxtPresenter[@taxon.headline_notes_taxt].to_antweb
    end

    def link_to_antcat
      Exporters::Antweb::Exporter.antcat_taxon_link @taxon
    end
end
