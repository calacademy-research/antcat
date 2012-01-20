# coding: UTF-8
module Catalog::IndexFormatter

  def format_taxon taxon, current_user
    header_name = format_header_name(taxon)
    status      = format_status(taxon)
    headline    = format_headline(taxon, current_user)
    statistics  = format_taxon_statistics(taxon)

    content_tag :div, :class => :antcat_taxon do
      contents = content_tag(:div, :class => :header) do
        content_tag(:span, header_name, :class =>  x_css_classes_for_taxon(taxon)) +
        content_tag(:span, status,      :class => :status)
      end
      contents << content_tag(:div,  statistics,:class => :statistics)
      contents << content_tag(:div,  headline,  :class => :headline)
      contents << format_history(taxon, current_user)
      contents
    end

  end

  def x_format_protonym_name name, rank, is_fossil
    classes = ['name', 'taxon']
    classes << 'genus' if rank == 'genus'
    classes << 'subfamily' if rank == 'family_or_subfamily'
    content_tag :span, :class => classes.sort.join(' ') do
      name_label name, is_fossil
    end
  end

  def x_format_headline_authorship authorship, user
    string = authorship.reference.key.to_link(user) + ": #{authorship.pages}"
    string << Taxt.to_string(authorship.notes_taxt)
    string << '.'
    content_tag :span, string, :class => :authorship
  end

  def x_format_headline_type_name taxon
    content_tag(:span, taxon.type_taxon_name.html_safe, :class => "#{taxon.type_taxon.rank} taxon")
  end

  def x_css_classes_for_taxon taxon
    "name taxon #{taxon.rank}"
  end

  #######################
  def format_header_name taxon
    taxon.full_name
  end

  def format_status taxon
    taxon.invalid? ? status_labels[taxon.status][:singular] : ''
  end

  #######################
  def format_headline taxon, user
    string = format_headline_protonym(taxon.protonym, user) + ' ' + format_headline_type(taxon)
    headline_notes = format_headline_notes taxon
    string << ' ' << headline_notes if headline_notes
    string
  end

  def format_headline_protonym protonym, user
    return '' unless protonym
    string = format_protonym_name protonym
    string << ' '
    string << format_headline_authorship(protonym.authorship, user)
    string
  end

  def format_protonym_name protonym
    string = x_format_protonym_name protonym.name, protonym.rank, protonym.fossil
  end

  def format_headline_authorship authorship, user
    return '' unless authorship
    contents = x_format_headline_authorship authorship, user
  end

  def format_headline_type taxon
    return '' unless taxon.type_taxon
    type = taxon.type_taxon
    taxt = taxon.type_taxon_taxt
    content_tag :span, :class => 'type' do
      string = "Type-#{type.type.downcase}: ".html_safe
      string << format_headline_type_name(taxon) + format_headline_type_taxt(taxt)
      string
    end
  end

  def format_headline_type_name taxon
    x_format_headline_type_name taxon
  end
  
  def format_headline_type_taxt taxt
    Taxt.to_string taxt
  end

  def format_headline_notes taxon
    return unless taxon.headline_notes_taxt.present?
    Taxt.to_string taxon.headline_notes_taxt
  end

  #######################
  def format_history taxon, user
    return '' unless taxon.taxonomic_history_items.present?
    history = taxon.taxonomic_history_items.inject(''.html_safe) do |history, history_item|
      history << format_history_item(history_item.taxt, user)
    end
    content_tag(:h4,  'Taxonomic history') +
    content_tag(:div, history, :class => :history)
  end

  def format_history_item taxt, user
    string = Taxt.to_string taxt, user
    string << '.'
    content_tag :div, string.html_safe, :class => :history_item
  end

end
