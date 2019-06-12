# This class is responsibe for preparing all tabs for `_taxon_browser.haml`.

module TaxonBrowser
  class Browser
    attr_reader :tabs, :display

    def initialize taxon, show_invalid, display
      @taxon = taxon
      @show_invalid = show_invalid
      @display = default_or_display display

      setup_tabs
    end

    def max_taxa_to_load
      500
    end

    def tab_by_id id
      tabs.find { |tab| tab.id == id }
    end

    def show_invalid?
      @show_invalid
    end

    def selected_in_tab? taxon
      taxon.in? taxon_and_ancestors
    end

    def tab_open? tab
      @tabs.last == tab
    end

    private

      def default_or_display display
        case @taxon
        when Subfamily then TaxonBrowser::Tab::ALL_GENERA_IN_SUBFAMILY if display.blank?
        when Subgenus  then TaxonBrowser::Tab::SUBGENERA_IN_PARENT_GENUS
        end || display
      end

      def setup_tabs
        @tabs = taxa_for_tabs.map do |taxon|
          Tabs::TaxonTab.new taxon, self
        end

        extra_tab = Tabs::ExtraTab.create @taxon, @display, self
        @tabs << extra_tab if extra_tab
      end

      # Follows the "main progression", which from the lowest rank and up is:
      # Subspecies -> Species -> Genus -> Tribe -> Subfamily -> Family.
      # See https://github.com/calacademy-research/antcat/wiki/For-developers
      def taxa_for_tabs
        # We do not want to include all ranks in the tabs.
        taxon_and_ancestors.reject do |taxon|
          # Never show the [children of] subspecies tab (has no children).
          taxon.is_a?(Subspecies) ||

            # Don't show [subspecies in] species tab unless the species has subspecies.
            (taxon.is_a?(Species) && !taxon.children.exists?) ||

            # Hide [species in] subgenus tab because there are none as of 2016.
            taxon.is_a?(Subgenus)
        end
      end

      def taxon_and_ancestors
        @taxon_and_ancestors ||= @taxon.taxon_and_ancestors
      end
  end
end
