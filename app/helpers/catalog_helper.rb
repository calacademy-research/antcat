module CatalogHelper

  def show_hide_menu #TODO
    items = []
    items << hide_or_show_unavailable_subfamilies_link(session[:show_unavailable_subfamilies])
    items <<  if session[:show_tribes]
                hide_link "tribes"
              else
                show_child_link "tribes"
              end

    items <<  if session[:show_subgenera]
                hide_link "subgenera"
              else
                show_child_link "subgenera"
              end
    make_link_menu items
  end

  # The "(no subfamily/tribe)"/"?child=none" links
  def incertae_sedis_column_link rank, taxon, selected_taxon, parent_taxon
    classes = 'valid'
    classes << ' selected' if taxon == selected_taxon
    link_to "(no #{rank})", catalog_path(parent_taxon, child: "none"), class: classes
  end

  def taxon_column_link taxon, selected_taxon
    classes = taxon_css_classes taxon, selected: taxon == selected_taxon
    label = taxon_label taxon
    link_to label, catalog_path(taxon), class: classes
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
    def hide_link name
      link_to "hide #{name}", "/catalog/hide_#{name}#{build_params}".html_safe
    end

    def hide_or_show_unavailable_subfamilies_link is_hiding_link
      command = is_hiding_link ? 'hide' : 'show'
      action = command.dup << '_unavailable_subfamilies'
      text = command + ' unavailable subfamilies'
      link_to text, "/catalog/#{action}#{build_params}".html_safe
    end

    def show_child_link name
      link_to "show #{name}", "/catalog/show_#{name}#{build_params}".html_safe
    end

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

end
