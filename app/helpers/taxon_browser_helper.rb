module TaxonBrowserHelper
  def taxon_browser_link taxon
    classes = css_classes_for_rank(taxon)
    classes << css_classes_for_status(taxon)
    link_to taxon_label(taxon), catalog_path(taxon), class: classes
  end

  def toggle_valid_only_link
    showing = !session[:show_invalid]

    label = showing ? "show invalid" : "show valid only"
    link_to label, catalog_options_path(valid_only: showing)
  end

  def already_showing_invalid_taxa?
    session[:show_invalid]
  end
end
