# coding: UTF-8
module Formatters::AdvancedSearchFormatter
  include ActionView::Helpers::TagHelper

  def format_status taxon
    return format_original_combination_status taxon if taxon.original_combination?
    labels = []
    labels << "#{italicize 'incertae sedis'} in #{Rank[taxon.incertae_sedis_in].to_s}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{format_name taxon.homonym_replaced_by}"
    elsif taxon.unidentifiable?
      labels << 'unidentifiable'
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.nomen_nudum?
      labels << italicize('nomen nudum')
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      label << senior_synonym_list(taxon)
      labels << label
    end
    labels << 'ichnotaxon' if taxon.ichnotaxon?
    labels.join(', ')
  end

  def format_original_combination_status taxon
    string = 'see '.html_safe
    string << format_name(taxon.current_valid_taxon)
    string
  end

  def format_protonym taxon, user
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << Formatters::ReferenceFormatter.format(reference)
    string << document_link(reference.key, user)
    string << goto_reference_link(reference.key)
    string << reference_id(reference)
    string
  end

  def document_link reference_key, user
    reference_key.document_link user
  end

  def goto_reference_link reference_key
    reference_key.goto_reference_link
  end

  def senior_synonym_list taxon
    return '' unless taxon.senior_synonyms.count > 0
    ' of ' << taxon.senior_synonyms.map {|e| format_name(e)}.join(', ')
  end

end
