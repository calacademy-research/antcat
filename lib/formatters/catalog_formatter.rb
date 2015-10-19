# coding: UTF-8
module Formatters::CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context
  extend AbstractController::Rendering

  extend Formatters::Formatter
  extend Formatters::LinkFormatter

  def self.taxon_label_span taxon, options = {}
    content_tag :span, class: taxon_css_classes(taxon, options) do
      taxon_label(taxon, options).html_safe
    end
  end

  def self.taxon_label taxon, options = {}
    epithet_label taxon.name, taxon.fossil?, options
  end

  def self.name_label name, fossil, options = {}
    name = name.to_html_with_fossil fossil
    name = name.upcase if options[:uppercase]
    name
  end

  def self.protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  def self.epithet_label name, fossil, options = {}
    name = name.epithet_with_fossil_html fossil
    name = name.upcase if options[:uppercase]
    name
  end

  def self.taxon_css_classes taxon, options = {}
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.downcase.gsub(/ /, '_') unless options[:ignore_status]
    css_classes << 'nomen_nudum' if taxon.nomen_nudum? unless options[:ignore_status]
    css_classes << 'collective_group_name' if taxon.collective_group_name? unless options[:ignore_status]
    css_classes << 'selected' if options[:selected]
    css_classes.sort.join ' '
  end

  def self.css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name']
  end

  # transform "10.11646/zootaxa.4029.1.1"
  # http://dx.doi.org/10.11646/zootaxa.4029.1.1
  # <a href="http://www.w3schools.com">Visit W3Schools</a>
  def self.create_link_from_doi doi
    #"<a href=\"http://dx.doi.org/" + doi + "\">#{doi}</a>"
    "http://dx.doi.org/" + doi

  end

  def self.format_doi_link reference
    unless reference.doi.nil? or reference.doi.length == 0
      link reference.doi, create_link_from_doi(reference.doi), class: 'document_link'
    end

  end


  def self.format_reference_document_link reference, user
    doi = format_doi_link(reference)
    pdf = link 'PDF', reference.url, class: 'document_link' if reference.downloadable_by? user
    if (doi)
      return doi + " " + pdf
    else
      return pdf
    end
  end

  # deprecated
  def self.taxon_label_and_css_classes taxon, options = {}
    {label: taxon_label(taxon, options), css_classes: taxon_css_classes(taxon, options)}
  end

end
