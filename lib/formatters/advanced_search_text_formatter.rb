# coding: UTF-8
module Formatters::AdvancedSearchTextFormatter
  include Formatters::Formatter
  include Formatters::AdvancedSearchFormatter

  def format taxon
    string = convert_to_text(format_name taxon)
    status = convert_to_text(format_status taxon)
    protonym = convert_to_text(format_protonym taxon, nil)
    string << convert_to_text(' ' + status) if status.present?
    string << "\n"
    string << convert_to_text(protonym) if protonym.present?
    string << "\n\n"
    string
  end

  def convert_to_text string
    unitalicize string.html_safe
  end

  def format_name taxon
    taxon.name_cache
  end

  def document_link _, __
  end

  def goto_reference_link _
  end

  def italicize string
    string
  end

  def reference_id reference
    "   #{reference.id.to_s}}"
  end

end
