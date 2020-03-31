# frozen_string_literal: true

# This class is responsibe for preparing all tabs for `_taxon_browser.haml`.

module TaxonBrowser
  class Browser
    attr_reader :display
    attr_accessor :tabs

    def initialize taxon, show_invalid, display
      @taxon = taxon
      @show_invalid = show_invalid
      @display = default_or_display display

      setup_tabs
    end

    def show_invalid?
      @show_invalid
    end

    def selected_in_tab? taxon
      taxon.in? taxon_and_ancestors
    end

    def tab_open? tab
      tabs.last == tab
    end

    private

      def default_or_display display
        case @taxon
        when Subfamily then Tab::ALL_GENERA_IN_SUBFAMILY if display.blank?
        when Subtribe  then Tab::SUBTRIBES_IN_PARENT_TRIBE
        when Subgenus  then Tab::SUBGENERA_IN_PARENT_GENUS
        end || display
      end

      def setup_tabs
        self.tabs = taxa_for_tabs.map do |taxon|
          Tabs::TaxonTab.new taxon, self
        end

        extra_tab = Tabs::ExtraTab.create @taxon, @display, self
        tabs << extra_tab if extra_tab
      end

      # Follows the "main progression", which from the lowest rank and up is:
      # Subspecies -> Species -> Genus -> Tribe -> Subfamily -> Family.
      # See https://github.com/calacademy-research/antcat/wiki/For-developers
      def taxa_for_tabs
        # We do not want to include all ranks in the tabs.
        taxon_and_ancestors.reject do |taxon|
          # Don't show [subspecies in] species tab unless the species has subspecies.
          (taxon.is_a?(Species) && !taxon.children.exists?) ||

            # Show "Camponotus > Componotus subgenera" instead of
            # "Camponotus > Camponotus (Myrmentoma) species > Componotus subgenera"
            # when a subgenus is selected.
            taxon.is_a?(Subgenus) && @taxon.is_a?(Subgenus) ||

            # Never show the [children of] subtribe tab (has no children).
            taxon.is_a?(Subtribe) ||

            # Never show the [children of] subtribe tab (has no children).
            taxon.is_a?(Infrasubspecies)
        end
      end

      def taxon_and_ancestors
        @_taxon_and_ancestors ||= Taxa::TaxonAndAncestors[@taxon]
      end
  end
end
