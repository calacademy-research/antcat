class AdvancedSearchPresenter
  class HTML < AdvancedSearchPresenter
    include Formatters::ItalicsHelper

    def format_name taxon
      taxon.link_to_taxon
    end
  end
end
