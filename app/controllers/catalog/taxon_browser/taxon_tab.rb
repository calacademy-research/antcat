module Catalog::TaxonBrowser
  class TaxonTab < Tab
    def initialize tab_taxon, taxon_browser
      @tab_taxon = tab_taxon
      children = tab_taxon.children.displayable
      super children, taxon_browser
    end

    def title
      return @tab_taxon.taxon_label if show_only_genus_name?
      "#{@tab_taxon.taxon_label} #{@tab_taxon.childrens_rank_in_words}".html_safe
    end

    def notify_about_no_valid_children?
      @children.empty? && !is_a_subfamily_with_valid_genera_incertae_sedis?
    end

    private
      # Exception for subfamilies *only* containing genera that are
      # incertae sedis in that subfamily (that is Martialinae, #430173).
      def is_a_subfamily_with_valid_genera_incertae_sedis?
        return unless @tab_taxon.is_a? Subfamily
        @tab_taxon.genera_incertae_sedis_in.valid.exists?
      end

      # Tweak for the [species of] genus tab to change eg
      # "Lasius species > Lasius subgenera" to "Lasius > Lasius subgenera".
      def show_only_genus_name?
        return unless @tab_taxon.is_a? Genus
        display.in? [ :all_taxa_in_genus,
                      :subgenera_in_genus,
                      :subgenera_in_parent_genus ]
      end
  end
end
