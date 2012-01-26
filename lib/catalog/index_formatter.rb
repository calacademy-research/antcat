# coding: UTF-8
module Catalog::IndexFormatter

  def format_taxon taxon, current_user
    header_name = format_header_name(taxon)
    status      = format_status(taxon)
    headline    = format_headline(taxon, current_user)
    statistics  = format_taxon_statistics(taxon)

    content_tag :div, class: :antcat_taxon do
      contents = content_tag(:div, class: :header) do
        content_tag(:span, header_name, class: x_css_classes_for_taxon(taxon)) +
        content_tag(:span, status,      class: :status)
      end
      contents << content_tag(:div,  statistics,class: :statistics)
      contents << content_tag(:div,  headline,  class: :headline)
      contents << format_history(taxon, current_user)
      contents << format_child_lists(taxon, current_user)
      contents << format_references(taxon, current_user)
      contents
    end

  end

  def x_format_protonym_name name, rank, is_fossil
    classes = ['name', 'taxon']
    classes << 'genus' if rank == 'genus'
    classes << 'subfamily' if rank == 'family_or_subfamily'
    content_tag :span, class: classes.sort.join(' ') do
      name_label name, is_fossil
    end
  end

  def x_format_headline_authorship authorship, user
    string = authorship.reference.key.to_link(user) + ": #{authorship.pages}"
    string << Taxt.to_string(authorship.notes_taxt)
    string << '.'
    content_tag :span, string, class: :authorship
  end

  def x_format_headline_type_name taxon
    content_tag(:span, taxon.type_taxon_name.html_safe, class: "#{taxon.type_taxon.rank} taxon")
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
    content_tag :span, class: 'type' do
      string = "Type-#{type.type.downcase}: ".html_safe
      string << format_headline_type_name(taxon) + format_headline_type_taxt(taxt)
      string
    end
  end

  def format_headline_type_name taxon
    x_format_headline_type_name taxon
  end
  
  def format_headline_type_taxt taxt
    string = Taxt.to_string(taxt)
    string = '.' unless string.present?
    string
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
    content_tag(:div, history, class: :history)
  end

  def format_history_item taxt, user
    string = Taxt.to_string taxt, user
    string << '.'
    content_tag :div, string.html_safe, class: :history_item
  end

  #######################

  #######################
  def format_child_lists taxon, user
    content_tag(:div, class: :child_lists) do
      content = ''
      content << format_child_lists_for_rank(taxon, :tribes, "Tribe", "Tribes")
      content << format_child_lists_for_rank(taxon, :genera, "Genus", "Genera")
      content.html_safe
    end
  end

  def format_child_lists_for_rank parent, children_selector, singular_rank_name, plural_rank_name
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Family === parent && children_selector == :genera
      format_child_list_fossil_pairs parent, children_selector, singular_rank_name, plural_rank_name, incertae_sedis_in: 'family'
    elsif Subfamily === parent && children_selector == :genera
      format_child_list_fossil_pairs parent, children_selector, singular_rank_name, plural_rank_name, incertae_sedis_in: 'subfamily'
    else
      format_child_list_fossil_pairs parent, children_selector,singular_rank_name, plural_rank_name
    end
  end

  def format_child_list_fossil_pairs parent, children_selector, singular_rank_name, plural_rank_name, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = child_list_query parent, children_selector, extinct_conditions
    extant = child_list_query parent, children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present? && extant.present?

    format_child_list(parent, extant, singular_rank_name, plural_rank_name, specify_extinct_or_extant, extant_conditions) +
    format_child_list(parent, extinct, singular_rank_name, plural_rank_name, specify_extinct_or_extant, extinct_conditions)
  end

  def format_child_list parent, children, singular_rank_name, plural_rank_name, specify_extinct_or_extant, conditions = {}
    return '' unless children.present?

    label = ''.html_safe
    label << ((children.count > 1) ? plural_rank_name : singular_rank_name)

    if specify_extinct_or_extant
      label << ' ('
      label << (conditions[:fossil] ? 'extinct' : 'extant')
      label << ')'
    end

    if conditions[:incertae_sedis_in]
      label << ' <i>incertae sedis</i> in '.html_safe
    else
      label << ' of '
    end
    
    label << taxon_label_span(parent, ignore_status: true)
    label

    content_tag :div, class: :child_list do
      content = ''
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << format_child_list_items(children)
      content << '.'
      content.html_safe
    end
  end

  def child_list_query parent, children_selector, conditions = {}
    children = parent.send children_selector
    children = children.where fossil: !!conditions[:fossil] if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where incertae_sedis_in: incertae_sedis_in if incertae_sedis_in
    children = children.where status: 'valid'
    children
  end

  def format_child_list_items children
    children.sort_by(&:name).inject([]) do |children, child|
      label = taxon_label child
      css_classes = taxon_css_classes child, ignore_status: true
      children << content_tag(:span, label, class: css_classes)
      children
    end.join(', ').html_safe
  end

  #######################
  def format_references taxon, user
    return '' unless taxon.reference_sections.present?
    content_tag :div, class: :reference_sections do
      taxon.reference_sections.inject(''.html_safe) do |reference_sections, reference_section|
        reference_sections << format_reference_section(reference_section, user)
      end
    end
  end

  def format_reference_section reference_section, user
    content_tag :div, class: 'section' do
      content_tag(:h4, Taxt.to_string(reference_section.title), class: :title) +
      content_tag(:div, Taxt.to_string(reference_section.references), class: :references)
    end
  end

end
