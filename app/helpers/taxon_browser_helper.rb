module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_status(taxon) << taxon.rank
    link_to taxon.epithet_with_fossil, catalog_path(taxon), class: classes
  end

  def toggle_invalid_or_valid_only_link showing_invalid, label = nil
    if showing_invalid
      link_to append_refresh_icon(label || "show valid only"), catalog_show_valid_only_path
    else
      link_to append_refresh_icon(label || "show invalid"), catalog_show_invalid_path
    end
  end

  def load_tab_button taxon, tab
    link_to "Load all?", catalog_tab_path(taxon, tab),
      class: "btn-normal btn-tiny load-tab", data: { tab_id: tab.id }
  end

  def extra_tab_link tab_taxon, label, tab_display, taxon_browser_display
    css = if tab_display == taxon_browser_display
            "upcase selected"
          else
            "upcase smaller-white-label"
          end

    content_tag :li do
      content_tag :span, class: css do
        link_to label, catalog_path(tab_taxon, display: tab_display)
      end
    end
  end

  private

    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.tr(' ', '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end
end
