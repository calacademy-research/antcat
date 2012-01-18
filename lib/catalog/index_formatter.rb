# coding: UTF-8
module Catalog::IndexFormatter

  def format_taxon taxon, current_user
    header_name = format_header_name taxon
    status      = format_status taxon
    headline    = format_headline taxon, current_user
    history     = format_history taxon, current_user
    statistics  = format_taxon_statistics taxon

    content_tag :div, :class => :antcat_taxon do
      contents = ''
      contents << content_tag(:div, :class => :header) do
        content_tag(:span, header_name,  :class =>  "name taxon #{taxon.rank}") +
        content_tag(:span, status, :class => :status)
      end
      contents << content_tag(:div,  statistics,        :class => :statistics)
      contents << content_tag(:div,  headline,          :class => :headline)
      contents << content_tag(:h4,  'Taxonomic history') if history.present?
      contents << content_tag(:div,  history, :class => :history)
      contents.html_safe
    end

  end

  #######################
  def format_header_name taxon
    taxon.full_name.html_safe
  end

  def format_status taxon
    taxon.invalid? ? status_labels[taxon.status][:singular] : ''
  end

  #######################
  def format_headline taxon, user
    format_headline_protonym(taxon.protonym, user) + ' ' + format_headline_type(taxon)
  end

  def format_headline_protonym protonym, user
    return '' unless protonym
    string = format_protonym_name protonym
    string << ' ' << format_headline_authorship(protonym.authorship, user)
    string
  end

  def format_protonym_name protonym
    return '' unless protonym
    classes = ['name', 'taxon']
    classes << 'genus' if protonym.rank == 'genus'
    classes << 'subfamily' if protonym.rank == 'family_or_subfamily'
    content_tag :span, :class => classes.sort.join(' ') do
      name_label protonym.name, protonym.fossil
    end
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
    Taxt.to_string(taxt).html_safe
  end

  #######################
  def format_history taxon, user
    return '' unless taxon
    taxon.taxonomic_history_items.inject('') do |string, history_item|
      string << format_history_item(history_item.taxt, user)
    end.html_safe
  end

  def format_history_item taxt, user
    string = Taxt.to_string taxt, user
    string << '.'
    content_tag :div, string.html_safe, :class => :history_item
  end

  #######################
  def format_reference_document_link reference, user
    "<a class=\"document_link\" target=\"_blank\" href=\"#{reference.url}\">PDF</a>" if reference.downloadable_by? user
  end

end
