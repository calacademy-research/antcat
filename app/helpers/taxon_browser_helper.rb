module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_rank(taxon)
    classes << css_classes_for_status(taxon)
    link_to taxon_label(taxon), catalog_path(taxon), class: classes
  end

  def panel_header selected
    if show_only_genus_name? selected
      taxon_breadcrumb_label selected
    elsif selected.is_a? Taxon
      child_ranks = { family:    "subfamilies",
                      subfamily: "tribes",
                      tribe:     "genera",
                      genus:     "species",
                      subgenus:  "species",
                      species:   "subspecies" }
      child_rank = child_ranks[selected.rank.to_sym]
      "#{taxon_breadcrumb_label selected} #{child_rank}"
    else
      selected[:title_for_panel]
    end.html_safe
  end

  def all_genera_link selected
    extra_panel_link selected, "All genera", "all_genera_in_#{selected.rank}"
  end

  def all_taxa_link selected
    extra_panel_link selected, "All taxa", "all_taxa_in_#{selected.rank}"
  end

  def subgenera_link selected
    return if selected.displayable_subgenera.empty?
    extra_panel_link selected, "Subgenera", "subgenera_in_#{selected.rank}"
  end

  def incertae_sedis_link selected
    return if selected.genera_incertae_sedis_in.empty?
    extra_panel_link selected, "Incertae sedis", "incertae_sedis_in_#{selected.rank}"
  end

  def toggle_valid_only_link
    showing = session[:show_valid_only]
    label = showing ? "show invalid" : "show valid only"
    link_to label, catalog_options_path(valid_only: showing)
  end

  def is_last_panel? panel, panels
    panels.last == panel
  end

  private
    def extra_panel_link selected, label, param
      css_class = if params[:display] == param
                    "upcase selected"
                  else
                    "upcase white-label"
                  end
      content_tag :li do
        content_tag :span, class: css_class do
          link_to label, catalog_path(selected, display: param)
        end
      end
    end

    # For the "All taxa" and "Subgenera" special cases, because
    # this would be confusing/false:
    #   "Formicidae ... Lasius species > Lasius subgenera"
    #   "Formicidae ... Lasius species > All Lasius taxa"
    def show_only_genus_name? selected
      selected.is_a?(Genus) &&
      params[:display].in?([
        "all_taxa_in_genus",
        "subgenera_in_genus",
        "subgenera_in_parent_genus"
      ])
    end
end
