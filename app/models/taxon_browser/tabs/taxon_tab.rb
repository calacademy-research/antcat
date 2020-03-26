# frozen_string_literal: true

# A `TaxonTab` requires a taxon for which `#children` returns something.
# TODO: This needs a rehaul.

module TaxonBrowser
  module Tabs
    class TaxonTab < Tab
      attr_reader :tab_taxon

      def initialize tab_taxon, taxon_browser
        @tab_taxon = tab_taxon
        super tab_taxon.children, taxon_browser
      end

      def id
        "tab-taxon-#{tab_taxon.id}"
      end

      def title
        return tab_taxon.name_with_fossil if use_epithet_as_title?
        "#{tab_taxon.name_with_fossil} #{tab_taxon.childrens_rank_in_words}".html_safe
      end

      def notify_about_no_valid_taxa?
        taxa_in_tab.empty?
      end

      private

        # Changes "Formicinae tribes > ... > Lasiini genera > Lasiini subtribes" to
        #         "Formicinae tribes > ... > Lasiini > Lasiini subtribes".
        #
        # Changes "Formicinae tribes > ... > Lasius species > Lasius subgenera" to
        #         "Formicinae tribes > ... > Lasius > Lasius subgenera".
        def use_epithet_as_title?
          return false unless tab_taxon.is_a?(Tribe) || tab_taxon.is_a?(Genus)

          display.in?([SUBTRIBES_IN_TRIBE, SUBTRIBES_IN_PARENT_TRIBE]) ||
            display.in?([ALL_TAXA_IN_GENUS, SUBGENERA_IN_GENUS, SUBGENERA_IN_PARENT_GENUS])
        end
    end
  end
end
