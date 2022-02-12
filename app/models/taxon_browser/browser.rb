# frozen_string_literal: true

module TaxonBrowser
  class Browser
    attr_reader :view
    attr_accessor :tabs

    def initialize taxon, show_invalid, view
      @taxon = taxon
      @show_invalid = show_invalid
      @view = default_or_view view

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

      def default_or_view view
        case @taxon
        when Subfamily then Tab::ALL_GENERA_IN_SUBFAMILY if view.blank?
        when Subtribe  then Tab::SUBTRIBES_IN_PARENT_TRIBE
        when Subgenus  then Tab::SUBGENERA_IN_PARENT_GENUS
        end || view
      end

      def setup_tabs
        self.tabs = taxa_for_tabs.map do |taxon|
          Tabs::TaxonTab.new taxon, self
        end

        extra_tab = Tabs::ExtraTab.create @taxon, @view, self
        tabs << extra_tab if extra_tab
      end

      def taxa_for_tabs
        taxon_and_ancestors.reject do |taxon|
          # Don't show subspecies-belonging-to-species tab unless the species has subspecies.
          (taxon.is_a?(Species) && !taxon.immediate_children.exists?) ||

            # When a subgenus is selected, show:
            # "Camponotus > Componotus subgenera" instead of
            # "Camponotus > Camponotus (Myrmentoma) species > Componotus subgenera"
            (taxon.is_a?(Subgenus) && @taxon.is_a?(Subgenus)) ||

            # Never show the children-of-subtribe tab (has no immediate children).
            taxon.is_a?(Subtribe) ||

            # Never show the children-of-infrasubspecies tab (has no immediate children).
            taxon.is_a?(Infrasubspecies)
        end
      end

      def taxon_and_ancestors
        @_taxon_and_ancestors ||= Taxa::TaxonAndAncestors[@taxon]
      end
  end
end
