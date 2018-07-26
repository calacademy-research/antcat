module Formatters::AdvancedSearchHtmlFormatter
  include Formatters::AdvancedSearchFormatter

  def format_name taxon
    taxon.decorate.link_to_taxon
  end

  def format_forms taxon
    return if taxon.protonym.authorship.forms.blank?
    string = 'Forms: '
    string << add_period_if_necessary(taxon.protonym.authorship.forms)
  end

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference
    reference.decorate.expandable_reference
  end
end
