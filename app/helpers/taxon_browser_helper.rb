module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_status(taxon) << taxon.rank
    link_to taxon.epithet_with_fossil, catalog_path(taxon), class: classes
  end

  def toggle_invalid_or_valid_only_link showing_invalid
    label, show_param = if showing_invalid
                          ['show valid only', Catalog::ToggleDisplaysController::VALID_ONLY]
                        else
                          ['show invalid', Catalog::ToggleDisplaysController::VALID_AND_INVALID]
                        end
    link_to append_refresh_icon(label), catalog_toggle_display_path(show: show_param), method: :put
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
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end
end
