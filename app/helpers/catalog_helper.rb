module CatalogHelper
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
    [taxon.type.downcase, 'taxon', 'name'].sort
  end

  def link_to_edit_taxon taxon
    if user_can_edit?
      link_to "Edit", edit_taxa_path(taxon), class: "btn-edit"
    end
  end

  def link_to_add_new_species taxon
    return unless user_can_edit? && taxon.is_a?(Genus)

    link_to "Add species",
      new_taxa_path(rank_to_create: "species", parent_id: taxon.id),
      class: "btn-new"
  end

  def link_to_review_change taxon
    return unless user_can_review_changes?

    if taxon.can_be_reviewed? && taxon.last_change
      link_to 'Review change', "/changes/#{taxon.last_change.id}", class: "btn-normal"
    end
  end

  def link_to_superadmin_delete_taxon taxon
    return unless user_is_superadmin?

    link_to 'Delete', "#", id: "delete_button", class: "btn-delete",
      data: { 'delete-location' => taxa_path(taxon), "taxon-id" => taxon.id }
  end

  def show_full_statistics? taxon
    taxon.invalid? || params[:include_full_statistics].present?
  end

  private
    def css_classes_for_status taxon
      css_classes = []
      css_classes << taxon.status.downcase.gsub(/ /, '_')
      css_classes << 'nomen_nudum' if taxon.nomen_nudum?
      css_classes << 'collective_group_name' if taxon.collective_group_name?
      css_classes
    end
end
