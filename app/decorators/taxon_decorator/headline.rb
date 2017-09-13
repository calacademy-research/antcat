class TaxonDecorator::Headline
  include ActionView::Helpers
  include ActionView::Context
  include ApplicationHelper

  def initialize taxon, for_antweb: false
    @taxon = taxon
    @for_antweb = for_antweb
  end

  def call
    content_tag :div, class: 'headline' do
      notes = headline_notes
      hol_link = link_to_hol(@taxon)
      string = headline_protonym
      string << ' ' << headline_type
      string << ' ' << notes if notes
      string << ' ' << link_to_other_site if link_to_other_site
      string << ' ' << link_to_antwiki(@taxon) if link_to_antwiki(@taxon)
      string << ' ' << hol_link if hol_link
      string
    end
  end

  private
    def headline_protonym
      TaxonDecorator::HeadlineProtonym.new(@taxon, for_antweb: @for_antweb).call
    end

    def headline_type
      TaxonDecorator::HeadlineType.new(@taxon, for_antweb: @for_antweb).call
    end

    def headline_notes
      return unless @taxon.headline_notes_taxt.present?
      if for_antweb?
        TaxtPresenter[@taxon.headline_notes_taxt].to_antweb
      else
        TaxtPresenter[@taxon.headline_notes_taxt].to_html
      end
    end

    # TODO refactor more. Formerly based on `$use_ant_web_formatter`.
    def for_antweb?
      @for_antweb
    end

    def link_to_other_site
      if for_antweb?
        Exporters::Antweb::Exporter.antcat_taxon_link @taxon
      else
        link_to_antweb @taxon
      end
    end
end
