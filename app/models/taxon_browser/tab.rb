# Abstract class subclassed by the other two tab types.
#
# * `@taxa` are all the taxa shown when the tab is active.
# * `@tab_taxon` is the "owner" or "parent" of the taxa in the tab.
# * `@taxon` -- there's no such thing here!

module TaxonBrowser
  class Tab
    TABS = [
      INCERTAE_SEDIS_IN_FAMILY    = :incertae_sedis_in_family,
      INCERTAE_SEDIS_IN_SUBFAMILY = :incertae_sedis_in_subfamily,
      WITHOUT_TRIBE               = :without_tribe,
      ALL_GENERA_IN_FAMILY        = :all_genera_in_family,
      ALL_GENERA_IN_SUBFAMILY     = :all_genera_in_subfamily,
      ALL_TAXA_IN_GENUS           = :all_taxa_in_genus,
      SUBGENERA_IN_GENUS          = :subgenera_in_genus,
      SUBGENERA_IN_PARENT_GENUS   = :subgenera_in_parent_genus
    ]

    attr_accessor :tab_taxon

    delegate :display, :selected_in_tab?, :tab_open?,
      :show_invalid?, :max_taxa_to_load, to: :@taxon_browser

    def initialize taxa_in_tab, taxon_browser
      @taxon_browser = taxon_browser
      @taxa_in_tab = taxa_in_tab
      @taxa_in_tab = taxa_in_tab.valid unless show_invalid?
    end

    def to_param
      id
    end

    def taxa_count
      @taxa_count ||= taxa_in_tab.count
    end

    def too_many_taxa_to_load?
      taxa_count > max_taxa_to_load
    end

    def each_taxon cap: false
      limit = max_taxa_to_load if cap

      sorted_taxa.limit(limit).includes(:name).each do |taxon|
        yield taxon, selected_in_tab?(taxon)
      end
    end

    def open?
      tab_open? self
    end

    private

      attr_reader :taxa_in_tab

      def sorted_taxa
        taxa_in_tab.order_by_epithet
      end
  end
end
