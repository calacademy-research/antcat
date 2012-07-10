# coding: UTF-8
class Formatters::CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context

  extend Formatters::Formatter
  extend Formatters::StatisticsFormatter

  def self.taxon_label_span taxon, options = {}
    content = content_tag :span, class: taxon_css_classes(taxon, options) do
      taxon_label(taxon, options).html_safe
    end
    content << ' (unresolved junior homonym)' if Status[taxon.status] == Status['unresolved homonym'] && options[:indicate_unresolved_junior_homonym]
    content
  end

  def self.taxon_label taxon, options = {}
    name_label taxon.name.html_epithet.html_safe, taxon.fossil?, options
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
    [taxon.type.downcase, 'taxon', 'name']
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
    {label: taxon_label(taxon, options), css_classes: taxon_css_classes(taxon, options)}
  end

  def self.format_header_name taxon
    taxon.name.to_html.html_safe
  end

  def self.format_status taxon
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[taxon.incertae_sedis_in].to_s}" if taxon.incertae_sedis_in
    if taxon.homonym? && taxon.homonym_replaced_by
      labels << "homonym replaced by #{taxon_label_span(taxon.homonym_replaced_by, ignore_status: true)}"
    elsif taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif taxon.invalid?
      label = Status[taxon].to_s.dup
      label << ' of ' << taxon_label_span(taxon.synonym_of, ignore_status: true) if taxon.synonym? && taxon.synonym_of
      labels << label
    end
    labels.join(', ').html_safe
  end

  def self.format_headline taxon, user
    string = format_headline_protonym(taxon.protonym, user) + ' ' + format_headline_type(taxon, user)
    headline_notes = format_headline_notes taxon, user
    string << ' ' << headline_notes if headline_notes
    string
  end

  def self.format_headline_protonym protonym, user
    return ''.html_safe unless protonym
    string = format_protonym_name protonym
    string << ' ' << format_headline_authorship(protonym.authorship, user)
    string << format_locality(protonym.locality)
    string
  end

  def self.format_locality locality
    return '' unless locality.present?
    locality = locality.upcase.gsub(/\(.+?\)/) {|text| text.titlecase}
    add_period_if_necessary ' ' + locality
  end

  def self.format_protonym_name protonym
    classes = ['name', 'taxon']
    classes << 'genus' if protonym.name.rank == 'genus'
    classes << 'species' if protonym.name.rank == 'species'
    classes << 'subfamily' if protonym.name.rank == 'family_or_subfamily'
    content_tag :span, class: classes.sort.join(' ') do
      name_label protonym.name.to_html.html_safe, protonym.fossil
    end
  end

  def self.format_headline_authorship authorship, user
    return '' unless authorship
    string = authorship.reference.key.to_link(user) + ": #{authorship.pages}"
    string << " (#{authorship.forms})" if authorship.forms
    string << ' ' << Taxt.to_string(authorship.notes_taxt, user) if authorship.notes_taxt
    content_tag :span, string, class: :authorship
  end

  def self.format_headline_type taxon, user
    return '' unless taxon.type_name
    taxt = taxon.type_taxt
    rank = taxon.type_name.rank
    rank = 'genus' if rank == 'subgenus'
    content_tag :span, class: 'type' do
      string = "Type-#{rank}: ".html_safe
      string << format_headline_type_name(taxon) + format_headline_type_taxt(taxt, user)
      string
    end
  end

  def self.format_headline_type_name taxon
    rank = taxon.type_name.rank
    rank = 'genus' if rank == 'subgenus'
    content_tag :span, taxon.type_name.to_html.html_safe, class: "#{rank} taxon"
  end
  
  def self.format_headline_type_taxt taxt, user
    string = Taxt.to_string(taxt, user)
    string = '.' unless string.present?
    string
  end

  def self.format_headline_notes taxon, user
    return unless taxon.headline_notes_taxt.present?
    Taxt.to_string taxon.headline_notes_taxt, user
  end

  #######################
  def self.format_child_lists_for_rank parent, children_selector
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

  def self.format_child_list_fossil_pairs parent, children_selector, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = parent.child_list_query children_selector, extinct_conditions
    extant = parent.child_list_query children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present?

    format_child_list(parent, extant, specify_extinct_or_extant, extant_conditions) +
    format_child_list(parent, extinct, specify_extinct_or_extant, extinct_conditions)
  end

  def self.format_child_list parent, children, specify_extinct_or_extant, conditions = {}
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

  def self.format_child_list_items children
    children.sort_by(&:name).inject([]) do |string, child|
      string << taxon_label_span(child, ignore_status: true, indicate_unresolved_junior_homonym: true)
    end.join(', ').html_safe
  end

end
