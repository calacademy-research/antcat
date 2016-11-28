module Catalog::TaxonBrowser
  class ExtraTab < Tab
    def self.create taxon, taxon_browser
      return unless taxon_browser.display

      label = taxon.taxon_label

      title, children = case taxon_browser.display
        when :incertae_sedis_in_family, :incertae_sedis_in_subfamily
          [ "Genera <i>incertae sedis</i> in #{label}",
            taxon.genera_incertae_sedis_in ]
        when :all_genera_in_family, :all_genera_in_subfamily
          [ "All #{label} genera", taxon.all_displayable_genera ]
        when :all_taxa_in_genus
          [ "All #{label} taxa", taxon.displayable_child_taxa ]
        when :subgenera_in_genus
          [ "#{label} subgenera", taxon.displayable_subgenera ]
        when :subgenera_in_parent_genus
          [ "#{taxon.genus.taxon_label} subgenera",
            taxon.genus.displayable_subgenera ]
        else
          raise
        end

      new title, children, taxon_browser
    end

    def initialize title, children, taxon_browser
      super children, taxon_browser
      @title = title.html_safe
    end

    def title
      @title
    end

    def notify_about_no_valid_children?
      false
    end

    private
      ## "All taxa" in genus must be sorted by `names.epithet`.
      def sorted_children
        return @children.order_by_joined_epithet if display == :all_taxa_in_genus
        super
      end
  end
end
