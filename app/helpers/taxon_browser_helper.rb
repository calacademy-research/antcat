module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_status(taxon) << taxon.rank
    link_to taxon.taxon_label, catalog_path(taxon), class: classes
  end

  def toggle_invalid_or_valid_only_link label = nil
    showin_invalid = @taxon_browser.show_invalid?

    if showin_invalid
      link_to (label.presence || "show valid only"), catalog_show_valid_only_path
    else
      link_to (label.presence || "show invalid"), catalog_show_invalid_path
    end
  end

  def load_tab_button taxon, tab
    link_to "Load all?", catalog_tab_path(taxon, tab),
      class: "btn-normal btn-tiny load-tab", data: { tab_id: tab.id }
  end

  # TODO try to move part of this to `TaxonBrowser`.
  # Some taxon tabs should have links to extra tabs.
  def links_to_extra_tabs selected
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

    # Only for Formicidae/subfamilies.
    def incertae_sedis_link selected
      return unless selected.genera_incertae_sedis_in.exists?
      extra_tab_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
    end

    # Only shown if the taxon is a genus with displayable subgenera
    # For example Lasius, http://localhost:3000/catalog/429161)
    def subgenera_link selected
      return unless selected.displayable_subgenera.exists?
      extra_tab_link selected, "Subgenera", :subgenera_in_genus
    end

    def extra_tab_link selected, label, param
      css = if @taxon_browser.display == param.to_sym
              "upcase selected"
            else
              "upcase white-label"
            end

      content_tag :li do
        content_tag :span, class: css do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end

    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.gsub(/ /, '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end
end
