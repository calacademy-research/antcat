module CatalogHelper

  def show_and_hide_links
    { unavailable_subfamilies: "unavailable subfamilies",
      tribes: "tribes",
      subgenera: "subgenera"
    }.map do |key, name|
      show_or_hide_link key, name
    end
  end

  # The "(no subfamily/tribe)"/"?child=none" links
  def incertae_sedis_column_link rank, taxon, selected_taxon, parent_taxon
    classes = ['valid']
    classes << 'selected' if taxon == selected_taxon

    link_to "(no #{rank})", catalog_path(parent_taxon, child: "none"), class: classes
  end

  def taxon_column_link taxon, selected_taxon
    classes = css_classes_for_rank(taxon)
    classes = css_classes_for_status(taxon)
    classes << 'selected' if taxon == selected_taxon

    link_to taxon_label(taxon), catalog_path(taxon), class: classes
  end

  def taxon_label_span taxon
    content_tag :span, class: css_classes_for_rank(taxon) do
      taxon_label(taxon).html_safe
    end
  end

  def taxon_label taxon
    taxon.name.epithet_with_fossil_html taxon.fossil?
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name']
  end

  # HACK -ish
  def is_last_panel? selected_item, rank
    selected_item.nil? ||             # no selected -> must be last
    selected_item.is_a?(Species) ||   # species is always last
    (selected_item == "none" && rank == :tribe) # special case
  end

  private
    def show_or_hide_link key, name
      show_option = session["show_#{key}".to_sym]
      verb = show_option ? "hide" : "show"
      link_to "#{verb} #{name}", "/catalog/#{verb}_#{key}#{build_params}".html_safe
    end

    def build_params
      hash = { id: params[:id], child: params[:child] }
      hash.compact!
      "?#{hash.to_query}" if hash.present?
    end

    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.gsub(/ /, '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end

end
