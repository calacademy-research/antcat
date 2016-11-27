module TaxonBrowserHelper
  # TODO move the "selected" CSS class logic to here.
  def taxon_browser_link taxon
    classes = css_classes_for_rank(taxon)
    classes << css_classes_for_status(taxon)
    link_to taxon_label(taxon), catalog_path(taxon), class: classes
  end

  # If `selected` is a taxon: <name> <immediate child rank in plural>.
  # So, family --> "Formicidae subfamilies"
  # But no taxon --> we have a non-standard panel.
  def panel_header_title selected
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

  def toggle_valid_only_link
    showing = !session[:show_invalid]

    label = showing ? "show invalid" : "show valid only"
    link_to label, catalog_options_path(valid_only: showing)
  end

  def is_last_panel? panel, panels
    panels.last == panel
  end

  # Collections containing taxa of a single rank can be sorted by `#.name_cache`,
  # but mixed collections (such as the "ALL TAXA" link) must be sorted by `names.epithet`.
  def sorted_children_for_panel selected, children
    if params[:display] == "all_taxa_in_genus" && selected.try(:key?, :title_for_panel)
      children.order_by_joined_epithet
    else
      children.order_by_name_cache
    end.includes(:name)
  end

  def notify_about_no_valid_children? children, taxon
    children.empty? && !is_a_subfamily_with_valid_genera_incertae_sedis?(taxon)
  end

  def already_showing_invalid_taxa?
    session[:show_invalid]
  end

  private
    # Exception for subfamilies *only* containing genera that are
    # incertae sedis in that subfamily (that is Martialinae, #430173).
    def is_a_subfamily_with_valid_genera_incertae_sedis? taxon
      return unless taxon.is_a? Subfamily
      taxon.genera_incertae_sedis_in.valid.exists?
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
