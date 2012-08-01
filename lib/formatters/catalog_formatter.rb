# coding: UTF-8

class Formatters::CatalogFormatter
  extend ERB::Util
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TextHelper
  extend ActionView::Helpers::NumberHelper
  extend ActionView::Context
  extend AbstractController::Rendering

  extend Formatters::Formatter
  extend Formatters::StatisticsFormatter

  def self.taxon taxon, user
    content_tag :div, class: 'antcat_taxon' do
      content = ''.html_safe
      content << header(taxon)
      content << statistics(taxon)
      content << genus_species_header_note(taxon, user)
      content << headline(taxon, user)
      content << history(taxon, user)
      content << child_lists(taxon, user)
      content << references(taxon, user)
      content
    end
  end

  def self.header taxon
    content_tag :div, class: 'header' do
      content = ''.html_safe
      content << content_tag(:span, format_header_name(taxon), class: css_classes_for_rank(taxon))
      content << ' '
      content << content_tag(:span, format_status(taxon), class: 'status')
      content
    end
  end

  def self.statistics taxon
    content_tag :div, format_taxon_statistics(taxon), class: 'statistics'
  end

  def self.genus_species_header_note taxon, user
    if taxon.genus_species_header_note.present?
      content_tag :div, format_genus_species_header_note(taxon, user), class: 'genus_species_header_note'
    end
  end

  def self.headline taxon, user
    content_tag :div, format_headline(taxon, user), class: 'headline'
  end

  def self.history taxon, user
    if taxon.taxonomic_history_items.present?
      content_tag :div, class: 'history' do
        content = ''.html_safe
        for item in taxon.taxonomic_history_items do
          css_class = "history_item item_#{item.id}"
          content << content_tag(:div, class: css_class, 'data-id' => item.id) do
            content_tag :table do
              content_tag :tr do
                inner_content = ''.html_safe
                inner_content << content_tag(:td, class: 'history_item_body') do
                  add_period_if_necessary Taxt.to_string item.taxt, user
                end
                inner_content
              end
            end
          end
        end
        content
      end
    end
  end

  def self.child_lists taxon, user
    content_tag :div, class: 'child_lists' do
      content = ''.html_safe
      content << format_child_lists_for_rank(taxon, :subfamilies)
      content << format_child_lists_for_rank(taxon, :tribes)
      content << format_child_lists_for_rank(taxon, :genera)
      content << format_collective_group_name_child_list(taxon)
      content
    end
  end

  def self.references taxon, user
    if taxon.reference_sections.present?
      content_tag :div, class: 'reference_sections' do
        for reference_section in taxon.reference_sections do
          content_tag :div, class: 'section' do
            [:title, :subtitle, :references].each do |field|
              if reference_section[field].present?
                content_tag :div, Taxt.to_string(reference_section[field], user), class: field
              end
            end
          end
        end
      end
    end
  end

  ###########
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
    format_fossil name, fossil 
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

  def self.format_fossil name, is_fossil
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
      label << format_synonyms(taxon)
      labels << label
    end
    labels.join(', ').html_safe
  end

  def self.format_synonyms taxon
    return '' unless taxon.senior_synonyms.count > 0
    ' of ' << taxon.senior_synonyms.map {|e| taxon_label_span(e, ignore_status: true)}.join(', ')
  end

  def self.format_genus_species_header_note taxon, user
    format_notes taxon.genus_species_header_note, user
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
    name = format_fossil taxon.type_name.to_html.html_safe, taxon.type_fossil
    content_tag :span, name, class: "#{rank} taxon"
  end
  
  def self.format_headline_type_taxt taxt, user
    string = Taxt.to_string(taxt, user)
    string = '.' unless string.present?
    string
  end

  def self.format_headline_notes taxon, user
    format_notes taxon.headline_notes_taxt, user
  end

  def self.format_notes taxt, user
    return unless taxt.present?
    Taxt.to_string taxt, user
  end

  #######################
  def self.format_child_lists_for_rank parent, children_selector
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Subfamily === parent && children_selector == :genera
      format_child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: false) +
      format_child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: true)
    else
      format_child_list_fossil_pairs parent, children_selector
    end
  end

  def self.format_collective_group_name_child_list parent
    children_selector = :collective_group_names
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?
    format_child_list parent, parent.send(children_selector), false, collective_group_names: true
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

    if conditions[:collective_group_names]
      label << Status['collective group name'].to_s(children.count, :capitalized)
    else
      label << Rank[children].to_s(children.count, conditions[:hong] ? nil : :capitalized)
    end

    if specify_extinct_or_extant
      label << ' ('
      label << (conditions[:fossil] ? 'extinct' : 'extant')
      label << ')'
    end

    if conditions[:incertae_sedis_in]
      label << ' <i>incertae sedis</i> in '.html_safe
    elsif conditions[:collective_group_names]
      label << ' in '
    else
      label << ' of '
    end
    
    label << taxon_label_span(parent, ignore_status: true)

    r = content_tag :div, class: :child_list do
      content = ''.html_safe
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << format_child_list_items(children)
      content << '.'
      content
    end
  end

  def self.format_child_list_items children
    children.inject([]) do |string, child|
      string << taxon_label_span(child, ignore_status: true, indicate_unresolved_junior_homonym: true)
    end.join(', ').html_safe
  end

end
