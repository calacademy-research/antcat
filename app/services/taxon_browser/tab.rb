# TODO convert to a module?

# Abstract class subclassed by the other two tab types.
#
# * `@taxa` are all the taxa shown when the tab is active.
# * `@tab_taxon` is the "owner" or "parent" of the taxa in the tab.
# * `@taxon` -- there's no such thing here!

module TaxonBrowser
  class Tab
    attr_accessor :tab_taxon

    delegate :display, :selected_in_tab?, :tab_open?,
      :show_invalid?, :max_taxa_to_load, to: :@taxon_browser

    def initialize taxa, taxon_browser
      @taxon_browser = taxon_browser
      @taxa = taxa
      @taxa = taxa.valid unless show_invalid?
    end

    def to_param
      id
    end

    def taxa_count
      @taxa_count ||= @taxa.count
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

      def sorted_taxa
        @taxa.order_by_name
      end
  end
end
