# coding: UTF-8
module AdvancedSearchesHelper

  def format_name taxon
    Formatters::CatalogTaxonFormatter.link_to_taxon taxon
  end

  def format_status taxon
    if taxon.original_combination?
      format_original_combination_status taxon
    end
  end

  def format_original_combination_status taxon
    string = 'see '.html_safe
    string << Formatters::CatalogTaxonFormatter.link_to_taxon(taxon.current_valid_taxon)
    string
  end

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << Formatters::ReferenceFormatter.format(reference)
    string << reference.key.document_link(current_user)
    string << reference.key.goto_reference_link
    string
  end

end
