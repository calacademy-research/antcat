# coding: UTF-8
module Formatters::IndexFormatter

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
    string << Taxt.to_string(authorship.notes_taxt, user)
    string << '.'
    content_tag :span, string, class: :authorship
  end

  def x_format_headline_type_name taxon
    rank = taxon.type_taxon_rank
    rank = 'genus' if rank == 'subgenus'
    content_tag(:span, taxon.type_taxon_name.html_safe, class: "#{rank} taxon")
  end

  def x_css_classes_for_taxon taxon
    "name taxon #{taxon.rank}"
  end

  #######################
  def format_header_name taxon
    taxon.full_name
  end

  def format_status taxon
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[taxon.incertae_sedis_in].to_s}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{taxon_label_span(taxon.homonym_replaced_by, ignore_status: true)}"
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      label << ' of ' << taxon_label_span(taxon.synonym_of, ignore_status: true) if taxon.synonym?
      labels << label
    end
    labels.join(', ').html_safe
  end

  #######################
  def format_headline taxon, user
    string = format_headline_protonym(taxon.protonym, user) + ' ' + format_headline_type(taxon, user)
    headline_notes = format_headline_notes taxon, user
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

  def format_headline_type taxon, user
    return '' unless taxon.type_taxon_name
    taxt = taxon.type_taxon_taxt
    rank = taxon.type_taxon_rank
    rank = 'genus' if rank == 'subgenus'
    content_tag :span, class: 'type' do
      string = "Type-#{rank}: ".html_safe
      string << format_headline_type_name(taxon) + format_headline_type_taxt(taxt, user)
      string
    end
  end

  def format_headline_type_name taxon
    x_format_headline_type_name taxon
  end
  
  def format_headline_type_taxt taxt, user
    string = Taxt.to_string(taxt, user)
    string = '.' unless string.present?
    string
  end

  def format_headline_notes taxon, user
    return unless taxon.headline_notes_taxt.present?
    Taxt.to_string taxon.headline_notes_taxt, user
  end

  def format_history_item taxt, user
    string = Formatters::ReferenceFormatter.add_period_if_necessary Taxt.to_string taxt, user
    content_tag :div, class: :history_item do
      content = content_tag :a, title: 'edit', href: '#', class: [:icon, :edit] do
        content_tag(:img, '', src: '/images/edit_off.png', :alt => 'edit').html_safe
      end.html_safe
      content << string.html_safe 
    end.html_safe
  end

  #######################
  def format_child_lists taxon, user
  end

  def format_child_lists_for_rank parent, children_selector
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Family === parent && children_selector == :genera
      format_child_list_fossil_pairs parent, children_selector, incertae_sedis_in: 'family'
    elsif Subfamily === parent && children_selector == :genera
      format_child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: false) +
      format_child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: true)
    else
      format_child_list_fossil_pairs parent, children_selector
    end
  end

  def format_child_list_fossil_pairs parent, children_selector, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = child_list_query parent, children_selector, extinct_conditions
    extant = child_list_query parent, children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present?

    format_child_list(parent, extant, specify_extinct_or_extant, extant_conditions) +
    format_child_list(parent, extinct, specify_extinct_or_extant, extinct_conditions)
  end

  def format_child_list parent, children, specify_extinct_or_extant, conditions = {}
    return ''.html_safe unless children.present?

    label = ''.html_safe

    label << 'Hong (2002) ' if conditions[:hong]
    label << Rank[children].to_s(children.count, conditions[:hong] ? nil : :capitalized)

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
      content = ''.html_safe
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << format_child_list_items(children)
      content << '.'
      content
    end
  end

  def child_list_query parent, children_selector, conditions = {}
    children = parent.send children_selector
    children = children.where fossil: !!conditions[:fossil] if conditions.key? :fossil
    incertae_sedis_in = conditions[:incertae_sedis_in]
    children = children.where incertae_sedis_in: incertae_sedis_in if incertae_sedis_in
    children = children.where hong: !!conditions[:hong] if conditions.key? :hong
    children = children.where "status = 'valid' OR status = 'unresolved homonym'"
    children
  end

  def format_child_list_items children
    children.sort_by(&:name).inject([]) do |children, child|
      label = taxon_label child
      css_classes = taxon_css_classes child, ignore_status: true
      content = content_tag(:span, label, class: css_classes)
      content << ' (unresolved junior homonym)' if child.status == Status['unresolved homonym'].to_s
      children << content
    end.join(', ').html_safe
  end

  #######################

  def format_reference_section reference_section, user
  end

end
