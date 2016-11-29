# TODO convert to a module?

# Abstract class subclassed by the other two tab types.
#
# * `@taxa` are all the taxa shown when the tab is active.
# * `@tab_taxon` is the "owner" or "parent" of the taxa in the tab.
# * `@taxon` -- there's no such thing here!

module Catalog::TaxonBrowser
  class Tab
    attr_accessor :tab_taxon

    delegate :display, :selected_in_tab?, :tab_open?,
      :show_invalid?, to: :@taxon_browser

    def initialize taxa, taxon_browser
      @taxon_browser = taxon_browser
      @taxa = taxa
      @taxa = taxa.valid unless show_invalid?
    end

    def each_taxon
      sorted_taxa.includes(:name).each do |taxon|
        yield taxon, selected_in_tab?(taxon)
      end
    end

    def open?
      tab_open? self
    end

    private
      def sorted_taxa
        @taxa.order_by_name_cache
      end
  end
end
