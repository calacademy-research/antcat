class TaxonDecorator::HeadlineType
  include Service
  include ApplicationHelper

  def initialize taxon, for_antweb: false
    @taxon = taxon
    @for_antweb = for_antweb
  end

  def call
    headline_type
  end

  private

    attr_reader :taxon

    delegate :type_taxt, :type_taxon, :biogeographic_region, to: :taxon

    def headline_type
      string = ''.html_safe
      string << type_name_and_taxt
      string << add_period_if_necessary(biogeographic_region)
      string.rstrip.html_safe
    end

    def type_name_and_taxt
      string = ''.html_safe

      if type_taxon
        type_rank = type_taxon.rank
        type_rank = 'genus' if type_rank == 'subgenus'

        string = "Type-#{type_rank}: ".html_safe
        string << link_to_taxon(type_taxon)
      end

      if type_taxt
        string << detax(type_taxt)
      end

      return '' if string.blank?
      add_period_if_necessary string
    end

    def detax taxt
      detaxed = if for_antweb?
                  add_period_if_necessary TaxtPresenter[taxt].to_antweb
                else
                  add_period_if_necessary TaxtPresenter[taxt].to_html
                end
      return "" if detaxed.blank?
      return detaxed if detaxed.start_with?(",")

      " ".html_safe << detaxed
    end

    # TODO refactor more. Formerly based on `$use_ant_web_formatter`.
    def for_antweb?
      @for_antweb
    end

    def link_to_taxon taxon
      if for_antweb?
        Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
      else
        taxon.decorate.link_to_taxon
      end
    end
end
