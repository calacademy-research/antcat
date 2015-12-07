# coding: UTF-8
module Formatters::AdvancedSearchHtmlFormatter
  include Formatters::AdvancedSearchFormatter
  include RefactorHelper

  def format_name taxon
    link_to_taxon taxon
  end

  def reference_id reference
    content_tag :span, reference.id.to_s.html_safe, class: 'reference_id'
  end

  def convert_to_text string
    string.html_safe
  end

end
