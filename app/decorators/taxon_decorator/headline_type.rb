class TaxonDecorator::HeadlineType
  include ActionView::Helpers
  include ActionView::Context
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

    delegate :type_taxt, :biogeographic_region, to: :taxon

    def headline_type
      string = ''.html_safe
      string << type_name_and_taxt
      string << add_period_if_necessary(biogeographic_region)
      string.rstrip.html_safe
    end

    def type_name_and_taxt
      if !taxon.type_name && type_taxt
        string = detax type_taxt
      else
        return ''.html_safe unless taxon.type_name
        rank = taxon.type_name.rank
        rank = 'genus' if rank == 'subgenus'
        string = "Type-#{rank}: ".html_safe
        string << type_name + detax(type_taxt)
        string
      end
      content_tag :span do
        add_period_if_necessary string
      end
    end

    # TODO does not work 100%, because names are not unique.
    def type_name
      type = Taxon.find_by_name taxon.type_name.name
      return link_to_taxon(type) if type

      content_tag :span do
        taxon.type_name.to_html_with_fossil taxon.type_fossil
      end
    end

    def detax taxt
      if for_antweb?
        add_period_if_necessary TaxtPresenter[taxt].to_antweb
      else
        add_period_if_necessary TaxtPresenter[taxt].to_html
      end
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
