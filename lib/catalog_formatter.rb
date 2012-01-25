# coding: UTF-8
class CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context

  extend Formatter
  extend Catalog::StatisticsFormatter
  extend Catalog::IndexFormatter
  extend Catalog::AntwebFormatter

  def self.taxon_label taxon, options = {}
    name_label taxon.name, taxon.fossil?, options
  end

  def self.name_label name, fossil, options = {}
    name = name.upcase if options[:uppercase]
    fossil name, fossil 
  end

  def self.taxon_css_classes taxon, options = {}
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.gsub(/ /, '_') unless options[:ignore_status]
    css_classes << 'selected' if options[:selected]
    css_classes.sort.join ' '
  end

  def self.css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon']
  end

  def self.fossil name, is_fossil
    string = ''
    string << '&dagger;' if is_fossil
    string << h(name)
    string.html_safe
  end

  def self.format_reference_document_link reference, user
    "<a class=\"document_link\" target=\"_blank\" href=\"#{reference.url}\">PDF</a>".html_safe if reference.downloadable_by? user
  end

  # deprecated
  def self.taxon_label_and_css_classes taxon, options = {}
    {:label => taxon_label(taxon, options), :css_classes => taxon_css_classes(taxon, options)}
  end

end
