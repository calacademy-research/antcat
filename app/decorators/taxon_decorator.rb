class TaxonDecorator < ApplicationDecorator
  delegate_all

  def link_to_taxon
    link_to_taxon_with_label taxon.name_with_fossil
  end

  def link_to_taxon_with_label label
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def link_to_taxon_with_author_citation
    link_to_taxon_with_label(taxon.name_with_fossil) << ' ' << taxon.author_citation.html_safe
  end

  def link_each_epithet
    TaxonDecorator::LinkEachEpithet[taxon]
  end

  def id_and_name_and_author_citation
    h.content_tag :span do
      h.concat h.content_tag(:small, "##{taxon.id}", class: "gray")
      h.concat " "
      h.concat link_to_taxon
      h.concat " "
      h.concat h.content_tag(:small, author_citation, class: "gray")
    end
  end

  def statistics valid_only: false
    statistics = taxon.statistics valid_only: valid_only
    return '' unless statistics

    TaxonDecorator::Statistics[statistics]
  end

  def headline_protonym
    TaxonDecorator::HeadlineProtonym[taxon]
  end

  def headline_type
    TaxonDecorator::HeadlineType[taxon]
  end

  def child_lists for_antweb: false
    TaxonDecorator::ChildList[taxon, for_antweb: for_antweb]
  end

  def taxon_status
    TaxonDecorator::TaxonStatus[taxon]
  end
end
