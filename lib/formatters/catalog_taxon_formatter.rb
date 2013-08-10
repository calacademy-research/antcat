# coding: UTF-8
class Formatters::CatalogTaxonFormatter < Formatters::TaxonFormatter

  def include_invalid; true end
  def expand_references?; true end

  def link_to_other_site
    Exporters::Antweb::Formatter.link_to_antweb_taxon @taxon
  end

  def link_to_edit_taxon
    if @taxon.can_be_edited_by? @user
      content_tag :button, 'Edit', type: 'button', id: 'edit_button', 'data-edit-location' => "/taxa/#{@taxon.id}/edit"
    end
  end

  def link_to_review_change
    if @taxon.can_be_reviewed_by? @user
      content_tag :button, 'Review change', type: 'button', id: 'review_button', 'data-review-location' => "/changes/#{@taxon.last_change.id}"
    end
  end

end
