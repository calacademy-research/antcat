# TODO maybe less checking of user rights?
# TODO possibly DRY buttons helpers that may be duplicated elsewhere.

module CatalogHelper
  def link_to_edit_taxon taxon
    if user_can_edit?
      link_to "Edit", edit_taxa_path(taxon), class: "btn-normal"
    end
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
end
