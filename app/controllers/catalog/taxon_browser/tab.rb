module Catalog::TaxonBrowser
  class Tab
    attr_accessor :tab_taxon
    delegate :display, :selected_in_tab?, :tab_open?,
      :show_invalid?, to: :@taxon_browser

    def initialize children, taxon_browser
      @taxon_browser = taxon_browser
      @children = children
      @children = children.valid if show_invalid?
    end

    def each_child
      sorted_children.includes(:name).each do |child|
        yield child, selected_in_tab?(child)
      end
    end

    def open?
      tab_open? self
    end

    private
      def sorted_children
        @children.order_by_name_cache
      end
  end
end
