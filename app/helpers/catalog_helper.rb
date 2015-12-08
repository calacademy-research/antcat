# coding: UTF-8

module CatalogHelper

  def make_catalog_search_results_columns items
    column_count = 4
    snake items, column_count
  end

  def index_column_link rank, taxon, selected_taxon, parent_taxon, parameters = {}
    parameters = parameters.dup
    parameters.delete :id
    parameters.delete :child
    
    if taxon == 'none'
      parameters[:child] = 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      if rank == :subfamily
        id_string = ''
        label = '(no subfamily)'
      elsif rank == :tribe
        id_string = "/#{parent_taxon.id}"
        label = '(no tribe)'
      end
    else
      id_string = "/#{taxon.id}"
      label = taxon_label taxon
      classes = taxon_css_classes taxon, selected: taxon == selected_taxon
    end

    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to label, "/catalog#{id_string}#{parameters_string}", class: classes
  end

  def search_result_link item, parameters, search_query, st="bw"
    parameters = parameters.dup
    
    css_class = item[:id].to_s == parameters[:id].to_s ? 'selected' : nil

    parameters[:qq] = search_query
    parameters[:id] = item[:id]
    parameters[:st] = st
    parameters.delete :child

    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to raw(item[:name]), "/catalog/search#{parameters_string}", class: css_class
  end

  def hide_link name, selected, parameters
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to 'hide', "/catalog/hide_#{name}#{parameters_string}"
  end

  def hide_or_show_unavailable_subfamilies_link is_hiding_link, parameters
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    command = is_hiding_link ? 'hide' : 'show'
    action = command.dup << '_unavailable_subfamilies'
    text = command + ' unavailable'
    link_to text, "/catalog/#{action}#{parameters_string}"
  end

  def show_child_link name, selected, parameters
    parameters_string = parameters.empty? ? '' : "?#{parameters.to_query}"
    link_to "show #{name}", "/catalog/show_#{name}#{parameters_string}"
  end

  def snake_taxon_columns items
    column_count = case items.count
                   when 0..27 then 1
                   when 27..52 then 2
                   else 3 end
    css_class = 'taxon_item'
    css_class << ' teensy' if column_count == 3
    [snake(items, column_count), css_class]
  end

  def clear_search_results_link id
    path = if id.present?
      catalog_path id
    else
      root_path
    end
    link_to "Clear", path
  end

  def taxon_label_span taxon, options = {}
    content_tag :span, class: taxon_css_classes(taxon, options) do
      taxon_label(taxon, options).html_safe
    end
  end

  def taxon_label taxon, options = {}
    epithet_label taxon.name, taxon.fossil?, options
  end

  # never called; deprecated?
  def name_label name, fossil, options = {}
    raise "opsie name_label was called"
    name = name.to_html_with_fossil fossil
    name = name.upcase if options[:uppercase]
    name
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  private def epithet_label name, fossil, options = {}
    name = name.epithet_with_fossil_html fossil
    name = name.upcase if options[:uppercase]
    name
  end

  private def taxon_css_classes taxon, options = {}
    css_classes = css_classes_for_rank taxon
    css_classes << taxon.status.downcase.gsub(/ /, '_') unless options[:ignore_status]
    css_classes << 'nomen_nudum' if taxon.nomen_nudum? unless options[:ignore_status]
    css_classes << 'collective_group_name' if taxon.collective_group_name? unless options[:ignore_status]
    css_classes << 'selected' if options[:selected]
    css_classes.sort.join ' '
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name']
  end

  # deprecated
  def taxon_label_and_css_classes taxon, options = {}
    {label: taxon_label(taxon, options), css_classes: taxon_css_classes(taxon, options)}
  end

  private
    def snake array, column_count
      array.in_groups(column_count).transpose
    end
end
