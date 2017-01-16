# A `TaxonTab` requires a taxon for which `#children` returns something.

module Catalog::TaxonBrowser::Tabs
  class TaxonTab < Catalog::TaxonBrowser::Tab
    def initialize tab_taxon, taxon_browser
      @tab_taxon = tab_taxon
      super tab_taxon.children.displayable, taxon_browser
    end

    def id
      "tab-taxon-#{@tab_taxon.id}"
    end

    def title
      return @tab_taxon.name_with_fossil if show_only_genus_name?
      "#{@tab_taxon.name_with_fossil} #{@tab_taxon.childrens_rank_in_words}".html_safe
    end

    def notify_about_no_valid_taxa?
      @taxa.empty? && !is_a_subfamily_with_valid_genera_incertae_sedis?
    end

    private
      # Exception for subfamilies *only* containing genera that are
      # incertae sedis in that subfamily (that is Martialinae, #430173).
      def is_a_subfamily_with_valid_genera_incertae_sedis?
        return unless @tab_taxon.is_a? Subfamily
        @tab_taxon.genera_incertae_sedis_in.valid.exists?
      end

      # Tweak for the [species in] genus tab title to change eg
      # "Lasius species > Lasius subgenera" to "Lasius > Lasius subgenera".
      def show_only_genus_name?
        return unless @tab_taxon.is_a? Genus
        display.in? [ :all_taxa_in_genus,
                      :subgenera_in_genus,
                      :subgenera_in_parent_genus ]
      end
  end
end
