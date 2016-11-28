# Some taxon browser panels have extra links which
# only are applicable to some ranks.

module TaxonBrowserExtraPanelLinksHelper
  def extra_tab_links selected
    links = []

    case selected
    when Family, Subfamily
      links << extra_tab_link(selected, "All genera", "all_genera_in_#{selected.rank}")
      links << incertae_sedis_link(selected)
    when Genus
      links << extra_tab_link(selected, "All taxa", "all_taxa_in_#{selected.rank}")
      links << subgenera_link(selected)
    end

    links.reject(&:blank?).join.html_safe
  end

 private
    # Only shown if the taxon is a genus with displayable subgenera
    # For example Lasius, http://localhost:3000/catalog/429161)
    def subgenera_link selected
      return unless selected.displayable_subgenera.exists?
      extra_tab_link selected, "Subgenera", :subgenera_in_genus
    end

    # Only for Formicidae/subfamilies.
    def incertae_sedis_link selected
      return unless selected.genera_incertae_sedis_in.exists?
      extra_tab_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
    end

    def extra_tab_link selected, label, param
      content_tag :li do
        content_tag :span, class: extra_tab_css(param) do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end

    def extra_tab_css param
      return "upcase selected" if @taxon_browser.display == param.to_sym
      "upcase white-label"
    end
end