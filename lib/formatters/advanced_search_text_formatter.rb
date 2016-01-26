module Formatters::AdvancedSearchTextFormatter
  include Formatters::AdvancedSearchFormatter

  def format_name taxon
    taxon.name_cache
  end

  def show_document_link?
    false
  end

  def show_goto_reference_link?
    false
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
