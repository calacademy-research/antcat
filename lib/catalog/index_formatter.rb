# coding: UTF-8
module Catalog::IndexFormatter

  def format_taxon taxon, current_user
    header_name       = format_header_name taxon
    taxon_status      = format_status taxon
    headline          = format_headline taxon, current_user
    taxonomic_history = format_taxonomic_history taxon, current_user
    statistics        = format_taxon_statistics taxon

    content_tag :div, :class => :antcat_taxon do
      contents = ''
      contents << content_tag(:div, :class => :header) do
        content_tag(:span, header_name,  :class =>  "taxon #{taxon.rank}") +
        content_tag(:span, taxon_status, :class => :status)
      end
      contents << content_tag(:div,  statistics,        :class => :statistics)
      contents << content_tag(:div,  headline,          :class => :headline)
      contents << content_tag(:h4,  'Taxonomic history') if taxonomic_history.present?
      contents << content_tag(:div,  taxonomic_history, :class => :taxonomic_history)
      contents.html_safe
    end

  end

  def format_header_name taxon
    taxon.kind_of?(::Taxon) ? taxon.full_name.html_safe : ''
  end

  def format_status taxon
    taxon && taxon.invalid? ? status_labels[taxon.status][:singular] : ''
  end

  def format_headline taxon, user
    format_headline_protonym(taxon, user) + ' ' + format_headline_type(taxon)
  end

  def format_headline_protonym taxon, user
    return '' unless taxon
    string = format_headline_name(taxon)
    string << ' ' << format_headline_authorship(taxon.protonym.authorship, user) if taxon.protonym
    string
  end

  def format_headline_name taxon
    return '' unless taxon && taxon != 'no_tribe' && taxon != 'no_subfamily' && taxon.protonym
    content_tag :span, taxon.protonym.name, :class => :family_group_name
  end

  def format_headline_authorship authorship, user
    return '' unless authorship
    content_tag :span, authorship.reference.key.to_link(user) +
      ": #{authorship.pages}.".html_safe, :class => :authorship
  end

  def format_headline_type taxon
    return '' unless taxon && taxon.type_taxon
    type = taxon.type_taxon
    taxt = taxon.type_taxon_taxt
    content_tag :span, :class => :type do
      "Type-#{type.type.downcase}: ".html_safe +
      format_headline_type_name(type) +
      format_headline_type_taxt(taxt) +
      '.'.html_safe
    end
  end

  def format_headline_type_name taxon
    content_tag(:span, taxon.full_name, :class => "#{taxon.rank} taxon").html_safe
  end

  def format_headline_type_taxt taxt
    Taxt.interpolate(taxt).html_safe
  end

  def format_reference_document_link reference, user
    "<a class=\"document_link\" target=\"_blank\" href=\"#{reference.url}\">PDF</a>" if reference.downloadable_by? user
  end

  def format_taxonomic_history taxon, user
    return '' unless taxon
    taxon.taxonomic_history_items.inject('') do |string, taxonomic_history_item|
      string << format_taxonomic_history_item(taxonomic_history_item.taxt, user)
    end.html_safe
  end

  def format_taxonomic_history_item taxt, user
    string = Taxt.interpolate taxt, user
    string << '.'
    content_tag :div, string.html_safe, :class => :taxonomic_history_item
  end

end
