# `ExtraTab`s are used for things where calling `#children` would
# not work or make sense. Everything here is a special case.

module TaxonBrowser::Tabs
  class ExtraTab < TaxonBrowser::Tab
    def self.create taxon, display, taxon_browser
      return unless display.present?

      name_html = taxon.name_with_fossil

      title, taxa = case display
        when :incertae_sedis_in_family, :incertae_sedis_in_subfamily
          [ "Genera <i>incertae sedis</i> in #{name_html}",
            taxon.genera_incertae_sedis_in ]

        when :all_genera_in_family, :all_genera_in_subfamily
          [ "All #{name_html} genera", taxon.all_displayable_genera ]

        when :all_taxa_in_genus
          [ "All #{name_html} taxa", taxon.displayable_child_taxa ]

        # Special case because:
        #   1) A genus' children are its species.
        #   2) There are no taxa with a `subgenus_id` as of 2016.
        #
        # The catalog page in this case will be that of a genus.
        when :subgenera_in_genus
          [ "#{name_html} subgenera", taxon.displayable_subgenera ]

        # Like above, but for subgenus catalog pages.
        when :subgenera_in_parent_genus
          [ "#{taxon.genus.name_with_fossil} subgenera",
            taxon.genus.displayable_subgenera ]

        else
          raise "It should not be possible to get here via the GUI."
        end

      new title, taxa, taxon_browser
    end

    def initialize title, taxa, taxon_browser
      super taxa, taxon_browser
      @title = title.html_safe
    end

    def id
      "extra-tab"
    end

    def title
      @title
    end

    def notify_about_no_valid_taxa?
      false
    end

    private
      def sorted_taxa
        # Sorted by epithet which is used for the link labels.
        return @taxa.order_by_joined_epithet if display == :all_taxa_in_genus
        super
      end
  end
end
