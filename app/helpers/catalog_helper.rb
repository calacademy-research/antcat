# TODO maybe less checking of user rights?
# TODO possibly DRY buttons helpers that may be duplicated elsewhere.

module CatalogHelper
  def taxon_label_span taxon
    content_tag :span, class: css_classes_for_rank(taxon) do
      taxon.taxon_label
    end
  end

  def protonym_label protonym
    protonym.name.protonym_with_fossil_html protonym.fossil
  end

  # Sorted to make test pass
  # TODO fix.
  def css_classes_for_rank taxon
    [taxon.type.downcase, 'taxon', 'name'].sort
  end

  def link_to_edit_taxon taxon
    if user_can_edit?
      link_to "Edit", edit_taxa_path(taxon), class: "btn-normal"
    end
  end

  # TODO maybe make it possible to add (incertae sedis) species/genera.
  def link_to_add_new_species taxon
    return unless user_can_edit? && taxon.is_a?(Genus)

    link_to "Add species",
      new_taxa_path(rank_to_create: "species", parent_id: taxon.id),
      class: "btn-normal"
  end

  def link_to_review_change taxon
    return unless user_can_review_changes?

    if taxon.can_be_reviewed? && taxon.last_change
      link_to 'Review change', "/changes/#{taxon.last_change.id}", class: "btn-normal"
    end
  end

  def confirm_before_superadmin_delete_button taxon
    return unless user_is_superadmin?
    link_to 'Delete...', confirm_before_delete_taxa_path(taxon), class: "btn-delete"
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
