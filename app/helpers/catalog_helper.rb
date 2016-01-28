module CatalogHelper

  def make_catalog_search_results_columns items
    column_count = 4
    snake items, column_count
  end

  def index_column_link rank, taxon, selected_taxon, parent_taxon
    if taxon == 'none'
      child = 'none'
      classes = 'valid'
      classes << ' selected' if taxon == selected_taxon
      if rank == :subfamily
        id_string = "/#{Family.first.id}"
        label = '(no subfamily)'
      elsif rank == :tribe
        id_string = "/#{parent_taxon.id}"
        label = '(no tribe)'
      end
    else
      child = nil
      id_string = "/#{taxon.id}"
      label = taxon_label taxon
      classes = taxon_css_classes taxon, selected: taxon == selected_taxon
    end

    parameter_string = child ? "?child=#{child}" : ''
    link_to label, "/catalog#{id_string}#{parameter_string}", class: classes
  end

  def hide_link name
    link_to 'hide', "/catalog/hide_#{name}#{build_params}".html_safe
  end

  def hide_or_show_unavailable_subfamilies_link is_hiding_link
    command = is_hiding_link ? 'hide' : 'show'
    action = command.dup << '_unavailable_subfamilies'
    text = command + ' unavailable'
    link_to text, "/catalog/#{action}#{build_params}".html_safe
  end

  def show_child_link name
    link_to "show #{name}", "/catalog/show_#{name}#{build_params}".html_safe
  end

  def snake_taxon_columns items
    column_count = case items.count
                   when 0..27  then 1
                   when 27..52 then 2
                   else             3
                   end

    css_class = 'taxon_item'
    css_class << ' teensy' if column_count == 3
    [snake(items, column_count), css_class]
  end

  def taxon_label_span(taxon, ignore_status: false)
    content_tag :span, class: taxon_css_classes(taxon, ignore_status: ignore_status) do
      taxon_label(taxon).html_safe
    end
  end

  def taxon_label taxon
    epithet_label taxon.name, taxon.fossil?
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name']
  end

  private
    def build_params
      hash = {
        id: params[:id],
        child: params[:child]
      }
      hash.compact!
      "?#{hash.to_query}" if hash.present?
    end

    def epithet_label name, fossil
      name.epithet_with_fossil_html fossil
    end

    def taxon_css_classes(taxon, selected: nil, ignore_status: false)
      css_classes = css_classes_for_rank taxon

      unless ignore_status
        css_classes << taxon.status.downcase.gsub(/ /, '_')
        css_classes << 'nomen_nudum' if taxon.nomen_nudum?
        css_classes << 'collective_group_name' if taxon.collective_group_name?
      end

      css_classes << 'selected' if selected
      css_classes.sort.join ' '
    end

    def snake array, column_count
      transposed = array.in_groups(column_count).transpose
      transposed.map(&:compact)
    end
end
