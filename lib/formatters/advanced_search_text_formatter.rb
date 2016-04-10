module Formatters::AdvancedSearchTextFormatter
  include Formatters::AdvancedSearchFormatter

  def format_name taxon
    taxon.name_cache
  end

  def format_protonym taxon
    reference = taxon.protonym.authorship.reference

    string = ''.html_safe
    string << reference.decorate.format
    string << " DOI: " << reference.doi if reference.doi.present?
    string << "   #{reference_id(reference)}" if reference_id(reference)
    string
  end

  def italicize string
    string
  end

  def reference_id reference
    reference.id
  end

  def convert_to_text string
    unitalicize string.html_safe
  end

end
