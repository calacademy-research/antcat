# coding: UTF-8
module Formatters::AdvancedSearchHtmlFormatter
  include Formatters::AdvancedSearchFormatter

  def format_name taxon
    Formatters::CatalogTaxonFormatter.link_to_taxon taxon
  end

  def italicize string
    Formatters::Formatter.italicize string
  end

  def reference_id reference
    content_tag :span, reference.id.to_s, class: 'reference_id'
  end

end
