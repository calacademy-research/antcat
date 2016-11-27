# Some taxon browser panels have extra links which
# only are applicable to some ranks.

module TaxonBrowserExtraPanelLinksHelper
  def extra_panel_links_for_selected selected
    links = []

    if selected.is_a?(Family) || selected.is_a?(Subfamily)
      links << all_genera_link(selected)
      links << incertae_sedis_link(selected)
    end

    if selected.is_a?(Genus)
      links << all_taxa_link(selected)
      links << subgenera_link(selected)
    end

    links.reject(&:blank?).join.html_safe
  end

 private
    # Only for Formicidae/subfamilies.
    def all_genera_link selected
      extra_panel_link selected, "All genera", "all_genera_in_#{selected.rank}"
    end

    # Only shown on genus pages. The TB defaults to showing all valid species
    # in the selected genus. "ALL TAXA" also includes subspecies (and possible more?).
    def all_taxa_link selected
      extra_panel_link selected, "All taxa", "all_taxa_in_#{selected.rank}"
    end

    # Only shown if the taxon is a genus with subgenera
    # For example Lasius, http://localhost:3000/catalog/429161)
    def subgenera_link selected
      return unless selected.displayable_subgenera.exists?
      extra_panel_link selected, "Subgenera", "subgenera_in_#{selected.rank}"
    end

    # Only for Formicidae/subfamilies.
    def incertae_sedis_link selected
      return unless selected.genera_incertae_sedis_in.exists?
      extra_panel_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
    end

    def extra_panel_link selected, label, param
      content_tag :li do
        content_tag :span, class: extra_panel_link_css(param) do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end

    def extra_panel_link_css param
      return "upcase selected" if params[:display] == param
      "upcase white-label"
    end
end