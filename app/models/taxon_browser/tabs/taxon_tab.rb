# A `TaxonTab` requires a taxon for which `#children` returns something.
# TODO: This needs a rehaul.

# Things we may want to show:
# * Excluded [from Formicidae]
# * All incertae sedis [in Formicidae]

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
        taxa_in_tab.empty? && !subfamily_with_valid_genera_incertae_sedis?
      end

      private

        # Exception for subfamilies *only* containing genera that are
        # incertae sedis in that subfamily (that is Martialinae, #430173).
        def subfamily_with_valid_genera_incertae_sedis?
          return unless tab_taxon.is_a? Subfamily
          tab_taxon.genera_incertae_sedis_in.valid.exists?
        end

        # Changes "Formicinae tribes > ... > Lasiini genera > Lasiini subtribes" to
        #         "Formicinae tribes > ... > Lasiini > Lasiini subtribes".
        #
        # Changes "Formicinae tribes > ... > Lasius species > Lasius subgenera" to
        #         "Formicinae tribes > ... > Lasius > Lasius subgenera".
        def use_epithet_as_title?
          return unless tab_taxon.is_a?(Tribe) || tab_taxon.is_a?(Genus)

          display.in?([SUBTRIBES_IN_TRIBE, SUBTRIBES_IN_PARENT_TRIBE]) ||
            display.in?([ALL_TAXA_IN_GENUS, SUBGENERA_IN_GENUS, SUBGENERA_IN_PARENT_GENUS])
        end
    end
  end
end
