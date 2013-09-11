# coding: UTF-8
module Formatters::AdvancedSearchTextFormatter
  include Formatters::Formatter
  include Formatters::AdvancedSearchFormatter

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
    "   #{reference.id.to_s}"
  end

  def convert_to_text string
    unitalicize string.html_safe
  end

end
