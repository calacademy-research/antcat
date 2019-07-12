# `ExtraTab`s are used for things where calling `#children` would
# not work or make sense. Everything here is a special case.

# TODO: Refactor.

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

          # Special case because subgenera are outside of the "main progression".
          when SUBGENERA_IN_GENUS # The catalog page in this case will be that of a genus.
            ["#{name_html} subgenera", taxon.displayable_subgenera]

          when SUBGENERA_IN_PARENT_GENUS # Like above, but for subgenus catalog pages.
            ["#{taxon.genus.name_with_fossil} subgenera", taxon.genus.displayable_subgenera]

          # Special case because subtribes are outside of the "main progression".
          when SUBTRIBES_IN_TRIBE # The catalog page in this case will be that of a tribe.
            ["#{name_html} subtribes", taxon.displayable_subtribes]

          when SUBTRIBES_IN_PARENT_TRIBE # Like above, but for subtribe catalog pages.
            ["#{taxon.tribe.name_with_fossil} subtribes", taxon.tribe.displayable_subtribes]

          else
            raise "Unknown display option '#{display}' for <#{taxon.type} id: #{taxon.id}>"
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
