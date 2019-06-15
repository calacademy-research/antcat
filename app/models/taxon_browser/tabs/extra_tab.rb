# `ExtraTab`s are used for things where calling `#children` would
# not work or make sense. Everything here is a special case.

module TaxonBrowser
  module Tabs
    class ExtraTab < Tab
      def self.create taxon, display, taxon_browser
        return if display.blank?

        name_html = taxon.name_with_fossil

        title, taxa_in_tab =
          case display
          when INCERTAE_SEDIS_IN_FAMILY, INCERTAE_SEDIS_IN_SUBFAMILY
            ["Genera <i>incertae sedis</i> in #{name_html}", taxon.genera_incertae_sedis_in]

          when WITHOUT_TRIBE
            ["#{name_html} genera without tribe", taxon.genera_without_tribe]

          when ALL_GENERA_IN_FAMILY, ALL_GENERA_IN_SUBFAMILY
            ["All #{name_html} genera", taxon.all_displayable_genera]

          when ALL_TAXA_IN_GENUS
            ["All #{name_html} taxa", taxon.displayable_child_taxa]

          # Special case because:
          #   1) A genus' children are its species.
          #   2) There are no taxa with a `subgenus_id` as of 2016.
          #
          # The catalog page in this case will be that of a genus.
          when SUBGENERA_IN_GENUS
            ["#{name_html} subgenera", taxon.displayable_subgenera]

          # Like above, but for subgenus catalog pages.
          when SUBGENERA_IN_PARENT_GENUS
            ["#{taxon.genus.name_with_fossil} subgenera", taxon.genus.displayable_subgenera]

          else
            raise "It should not be possible to get here via the GUI."
          end

        new title, taxa_in_tab, taxon_browser
      end

      def initialize title, taxa_in_tab, taxon_browser
        super taxa_in_tab, taxon_browser
        @title = title.html_safe
      end

      def id
        "extra-tab"
      end

      def title
        @title
      end

      def tab_taxon
      end

      def notify_about_no_valid_taxa?
        false
      end
    end
  end
end
