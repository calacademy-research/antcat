module BreadcrumbsHelper
  def taxon_breadcrumb_link taxon
    label = taxon_breadcrumb_label taxon
    link_to label, catalog_path(taxon)
  end

  # TODO move. Also used in `TaxonBrowserHelper`.
  def taxon_breadcrumb_label taxon
    string = ''.html_safe
    string << '&dagger;'.html_safe if taxon.fossil
    string << taxon.name_html_cache.html_safe
  end
end
