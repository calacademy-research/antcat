module Formatters::AdvancedSearchHtmlFormatter
  include Formatters::AdvancedSearchFormatter
  include ActionView::Helpers::TagHelper
  include ActionView::Context

  def format_name taxon
    taxon.decorate.link_to_taxon
  end

  def reference_id _reference; end

  def convert_to_text string
    string.html_safe
  end

end
