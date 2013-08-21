# coding: UTF-8
module AdvancedSearchesHelper

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference
    string = ''.html_safe
    string << Formatters::ReferenceFormatter.format(reference)
    string << reference.key.document_link(current_user)
    string << reference.key.goto_reference_link
    string
  end

end
