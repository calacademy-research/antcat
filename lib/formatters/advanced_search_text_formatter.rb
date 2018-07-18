module Formatters::AdvancedSearchTextFormatter
  include Formatters::AdvancedSearchFormatter

  def format taxon
    string = convert_to_text(format_name(taxon))
    status = format_status_reference(taxon).html_safe
    string << convert_to_text(' ' + status) if status.present?
    type_localities = format_type_localities(taxon)
    string << convert_to_text(' ' + type_localities) if type_localities.present?
    string << "\n"
    protonym = convert_to_text format_protonym taxon
    string << protonym if protonym.present?
    string << "\n\n"
  end

  def format_name taxon
    taxon.name_cache
  end

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference

    string = ''.html_safe
    string << reference.decorate.formatted
    string << " DOI: " << reference.doi if reference.doi?
    string << "   #{reference.id}"
    string
  end

  def italicize string
    string
  end

  def convert_to_text string
    unitalicize string.html_safe
  end
end
