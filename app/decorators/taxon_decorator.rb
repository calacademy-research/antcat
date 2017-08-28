class TaxonDecorator < ApplicationDecorator
  delegate_all

  def link_to_taxon
    link_to_taxon_with_label taxon.name_with_fossil
  end

  def link_to_taxon_with_label label
    helpers.link_to label, helpers.catalog_path(taxon)
  end

  def link_each_epithet
    TaxonDecorator::LinkEachEpithet.new(taxon).call
  end

  # Currently accepts very confusing arguments.
  # `include_invalid` tells `TaxonDecorator::Statistics` to remove
  # invalid taxa from the already generated hash of counts. This is the older method.
  # `valid_only` was written for performance reasons; it makes `Taxon#statistics`
  # ignore invalid taxa to begin with.
  def statistics valid_only: false, include_invalid: true
    statistics = taxon.statistics valid_only: valid_only
    return '' unless statistics

    content = TaxonDecorator::Statistics.new(statistics, include_invalid: include_invalid).call
    return '' if content.blank?

    helpers.content_tag :div, content, class: 'statistics'
  end

  def headline for_antweb: false
    TaxonDecorator::Headline.new(taxon, for_antweb: for_antweb).call
  end

  def child_lists for_antweb: false
    TaxonDecorator::ChildList.new(taxon, for_antweb: for_antweb).call
  end

  def taxon_status
    TaxonDecorator::TaxonStatus.new(taxon).call
  end
end
