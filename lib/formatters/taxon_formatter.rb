# coding: UTF-8
class Formatters::TaxonFormatter
  include ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TagHelper
  include ActionView::Context
  include Formatters::Formatter

  def initialize taxon, user = nil
    @taxon, @user = taxon, user
  end

  def format
    content_tag :div, class: 'antcat_taxon' do
      content = ''.html_safe
      content << header
      content << statistics(include_invalid: include_invalid)
      content << genus_species_header_notes_taxt
      content << headline
      content << history
      content << child_lists
      content << references
      content
    end
  end

  def include_invalid; true end

  ##########
  def header
    content_tag :div, class: 'header' do
      content = ''.html_safe
      content << content_tag(:span, header_name, class: Formatters::CatalogFormatter.css_classes_for_rank(@taxon))
      content << ' '
      content << content_tag(:span, status, class: 'status')
      content
    end
  end

  def header_link taxon, label
    link label, %{http://www.antcat.org/catalog/#{taxon.id}}, target: nil
  end

  def header_name
    string = ''.html_safe
    if @taxon.kind_of?(Species) or @taxon.kind_of?(Subspecies)
      genus = @taxon.genus
      string << header_link(genus, genus.name.to_html_with_fossil(genus.fossil?))
      string << ' '.html_safe
      if @taxon.kind_of? Species
        string << header_link(@taxon, @taxon.name.epithet_html.html_safe)
      else @taxon.kind_of? Subspecies
        species = @taxon.species
        if species
          string << header_link(species, species.name.epithet_html.html_safe)
          string << ' '.html_safe
          epithets_without_species = @taxon.name.epithets.split(' ')[1..-1].join ' '
          string << header_link(@taxon, italicize(epithets_without_species).html_safe)
        else
          string << header_link(@taxon, italicize(@taxon.name.epithets).html_safe)
        end
      end
    else
      string << header_link(@taxon, @taxon.name.to_html_with_fossil(@taxon.fossil?))
    end
    string
  end

  def status
    labels = []
    labels << "<i>incertae sedis</i> in #{Rank[@taxon.incertae_sedis_in].to_s}" if @taxon.incertae_sedis_in
    if @taxon.homonym? && @taxon.homonym_replaced_by
      labels << "homonym replaced by #{Formatters::CatalogFormatter.taxon_label_span(@taxon.homonym_replaced_by, ignore_status: true)}"
    elsif @taxon.unidentifiable
      labels << 'unidentifiable'
    elsif @taxon.unresolved_homonym?
      labels << "unresolved junior homonym"
    elsif @taxon.nomen_nudum?
      labels << "<i>nomen nudum</i>"
    elsif @taxon.invalid?
      label = Status[@taxon].to_s.dup
      label << senior_synonym_list
      labels << label
    end
    labels.join(', ').html_safe
  end

  def senior_synonym_list
    return '' unless @taxon.senior_synonyms.count > 0
    ' of ' << @taxon.senior_synonyms.map {|e| self.class.link_to_taxon(e)}.join(', ')
  end

  ##########
  def statistics options = {}
    statistics = @taxon.statistics or return ''
    content_tag :div, Formatters::StatisticsFormatter.statistics(statistics, options), class: 'statistics'
  end

  ##########
  def genus_species_header_notes_taxt
    if @taxon.genus_species_header_notes_taxt.present?
      content_tag :div, detaxt(@taxon.genus_species_header_notes_taxt), class: 'genus_species_header_notes_taxt'
    end
  end

  ##########
  def headline
    content_tag :div, class: 'headline' do
      string = headline_protonym + ' ' + headline_type
      notes = headline_notes
      string << ' ' << notes if notes
      string << ' ' << link_to_other_site if link_to_other_site
      string << ' ' << link_to_antwiki if link_to_antwiki
      string << ' ' << link_to_edit_taxon if link_to_edit_taxon
      string
    end
  end

  def headline_protonym
    protonym = @taxon.protonym
    return ''.html_safe unless protonym
    string = protonym_name protonym
    string << ' ' << headline_authorship(protonym.authorship)
    string << locality(protonym.locality)
    string
  end

  def headline_type
    taxt = @taxon.type_taxt
    if not @taxon.type_name and taxt
      string = headline_type_taxt taxt
    else
      return if not @taxon.type_name
      rank = @taxon.type_name.rank
      rank = 'genus' if rank == 'subgenus'
      string = "Type-#{rank}: ".html_safe
      string << headline_type_name + headline_type_taxt(taxt)
      string
    end
    content_tag :span, class: 'type' do
      string
    end
  end

  def headline_type_taxt taxt
    string = detaxt taxt
    string = '.' unless string.present?
    string
  end

  def headline_type_name
    rank = @taxon.type_name.rank
    rank = 'genus' if rank == 'subgenus'
    name = @taxon.type_name.to_html_with_fossil @taxon.type_fossil
    content_tag :span, name, class: "#{rank} taxon"
  end
  
  def protonym_name protonym
    content_tag :b, Formatters::CatalogFormatter.protonym_label(protonym)
  end

  def headline_authorship authorship
    return '' unless authorship
    string = reference_link(authorship.reference) + ": #{authorship.pages}"
    string << " (#{authorship.forms})" if authorship.forms
    string << ' ' << detaxt(authorship.notes_taxt) if authorship.notes_taxt
    content_tag :span, string, class: :authorship
  end

  def reference_link reference
    reference.key.to_link @user, expansion: expand_references?
  end

  def locality locality
    return '' unless locality.present?
    locality = locality.upcase.gsub(/\(.+?\)/) {|text| text.titlecase}
    add_period_if_necessary ' ' + locality
  end

  def headline_notes
    return unless @taxon.headline_notes_taxt.present?
    detaxt @taxon.headline_notes_taxt
  end

  def link_to_other_site
    Exporters::Antweb::Formatter.link_to_antweb_taxon @taxon
  end

  def link_to_antwiki
    Formatters::Formatter.link_to_external_site 'AntWiki', "http://www.antwiki.org/#{@taxon.name.to_s.gsub(/ /, '_')}"
  end

  def link_to_edit_taxon
    return unless $Environment.user_can_edit_catalog? @user
    content_tag :button, 'Edit', type: 'button', id: 'edit_button', 'data-edit-location' => "/taxa/#{@taxon.id}/edit"
  end

  ###########
  def self.link_to_antcat taxon, label = 'AntCat'
    Formatters::Formatter.link_to_external_site label, "http://www.antcat.org/catalog/#{taxon.id}"
  end

  def self.link_to_taxon taxon
    label = taxon.name.to_html_with_fossil(taxon.fossil?)
    content_tag :a, label, href: %{/catalog/#{taxon.id}}
  end

  ##########
  def history
    if @taxon.history_items.present?
      content_tag :div, class: 'history' do
        @taxon.history_items.inject(''.html_safe) do |content, item|
          content << history_item(item)
        end
      end
    end
  end

  def history_item item
    css_class = "history_item item_#{item.id}"
    content_tag :div, class: css_class, 'data-id' => item.id do
      content_tag :table do
        content_tag :tr do
          history_item_body item
        end
      end
    end
  end

  def history_item_body_attributes
    {}
  end

  def history_item_body item
    content_tag :td, history_item_body_attributes.merge(class: 'history_item_body') do
      add_period_if_necessary detaxt item.taxt
    end
  end

  ##########
  def child_lists
    content = ''.html_safe
    content << child_lists_for_rank(@taxon, :subfamilies)
    content << child_lists_for_rank(@taxon, :tribes)
    content << child_lists_for_rank(@taxon, :genera)
    content << collective_group_name_child_list(@taxon)
    return unless content.present?
    content_tag :div, class: 'child_lists' do
      content
    end
  end

  def child_lists_for_rank parent, children_selector
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?

    if Subfamily === parent && children_selector == :genera
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: false) +
      child_list_fossil_pairs(parent, children_selector, incertae_sedis_in: 'subfamily', hong: true)
    else
      child_list_fossil_pairs parent, children_selector
    end
  end

  def collective_group_name_child_list parent
    children_selector = :collective_group_names
    return '' unless parent.respond_to?(children_selector) && parent.send(children_selector).present?
    child_list parent, parent.send(children_selector), false, collective_group_names: true
  end

  def child_list_fossil_pairs parent, children_selector, conditions = {}
    extant_conditions = conditions.merge fossil: false
    extinct_conditions = conditions.merge fossil: true
    extinct = parent.child_list_query children_selector, extinct_conditions
    extant = parent.child_list_query children_selector, extant_conditions
    specify_extinct_or_extant = extinct.present?

    child_list(parent, extant, specify_extinct_or_extant, extant_conditions) +
    child_list(parent, extinct, specify_extinct_or_extant, extinct_conditions)
  end

  def child_list parent, children, specify_extinct_or_extant, conditions = {}
    label = ''.html_safe
    return label unless children.present?

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
    
    label << Formatters::CatalogFormatter.taxon_label_span(parent, ignore_status: true)

    content_tag :div, class: :child_list do
      content = ''.html_safe
      content << content_tag(:span, label, class: :label)
      content << ': '
      content << child_list_items(children)
      content << '.'
      content
    end
  end

  def child_list_items children
    children.inject([]) do |string, child|
      string << self.class.link_to_taxon(child)
    end.join(', ').html_safe
  end

  ############
  def references
    if @taxon.reference_sections.present?
      content_tag :div, class: 'reference_sections' do
        @taxon.reference_sections.inject(''.html_safe) do |content, section|
          content << reference_section(section)
        end
      end
    end
  end

  def reference_section section
    content_tag :div, class: 'section' do
      [:title_taxt, :subtitle_taxt, :references_taxt].inject(''.html_safe) do |content, field|
        if section[field].present?
          content << content_tag(:div, detaxt(section[field]), class: field)
        end
        content
      end
    end
  end

  ############
  def expand_references?; true end

  def detaxt taxt
    return '' unless taxt.present?
    Taxt.to_string taxt, @user, expansion: expand_references?, formatter: self.class
  end

  ############
  def parentage_string
    case @taxon
    when Family
      'Family'
    when Subfamily
      'Subfamily'
    when Tribe
       'Tribe'
    when Genus
       'Genus'
    when Subgenus
      @taxon.genus.name.name
    when Species
      @taxon.genus.name.name
    when Subspecies
      @taxon.species.try(:name).try(:name) || '(no species)'
    else
      raise
    end
  end

end
