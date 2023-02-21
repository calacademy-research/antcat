# frozen_string_literal: true

class TaxonBrowserPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers
  include IconHelper

  attr_private_initialize :taxon_browser

  def taxon_browser_taxon_link taxon
    label = (taxon.fossil_protonym? ? +'†' : +'') << taxon.name_epithet
    link_to label, catalog_path(taxon), class: [taxon.status.tr(' ', '-'), taxon.rank]
  end

  def toggle_invalid_or_valid_only_link
    label, show_param = if taxon_browser.show_invalid?
                          ['show valid only', Catalog::ToggleViewsController::VALID_ONLY]
                        else
                          ['show invalid', Catalog::ToggleViewsController::VALID_AND_INVALID]
                        end
    link_to append_refresh_icon(label), catalog_toggle_view_path(show: show_param), method: :put
  end

  def extra_tab_link tab_taxon, label, tab_view
    css = tab_view == taxon_browser.view ? "selected" : "label-white-smaller"
    tag.span link_to(label, catalog_path(tab_taxon, view: tab_view)), class: css
  end
end
