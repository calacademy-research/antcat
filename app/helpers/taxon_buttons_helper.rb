module TaxonButtonsHelper
  def link_to_edit_taxon taxon
    link_to "Edit", edit_taxa_path(taxon), class: "btn-normal"
  end

  def link_to_review_change taxon
    if taxon.can_be_reviewed? && taxon.last_change
      link_to 'Review change', "/changes/#{taxon.last_change.id}", class: "btn-tiny btn-normal"
    end
  end

  def add_child_button taxon
    child_ranks = { family:    "subfamily",
                    subfamily: "genus",
                    tribe:     "genus",
                    genus:     "species",
                    subgenus:  "species",
                    species:   "subspecies" }

    rank_to_add = child_ranks[taxon.rank.to_sym]
    return if rank_to_add.blank?

    url = new_taxa_path rank_to_create: rank_to_add, parent_id: taxon.id
    link_to "Add #{rank_to_add}", url, class: "btn-normal"
  end

  def add_tribe_button taxon
    return unless taxon.is_a?(Subfamily)

    url = new_taxa_path rank_to_create: 'tribe', parent_id: taxon.id
    link_to "Add tribe", url, class: "btn-normal"
  end

  def add_subgenus_button taxon
    return unless taxon.is_a?(Genus)

    url = new_taxa_path rank_to_create: 'subgenus', parent_id: taxon.id
    link_to "Add subgenus", url, class: "btn-normal"
  end

  def convert_to_subspecies_button taxon
    return unless taxon.is_a? Species

    url = new_taxa_convert_to_subspecies_path taxon
    link_to 'Convert to subspecies', url, class: "btn-normal"
  end

  def elevate_to_species_button taxon
    return unless taxon.is_a? Subspecies

    link_to 'Elevate to species', taxa_elevate_to_species_path(taxon),
      method: :post, class: "btn-warning",
      data: { confirm: "Are you sure you want to elevate this subspecies to species?" }
  end

  def delete_unreferenced_taxon_button taxon
    return if taxon.is_a? Family
    return if taxon.any_nontaxt_references?

    message = <<-MSG.squish
      Are you sure you want to delete this taxon? Note: It may take a few
      moments to check that this taxon isn't being referenced.
    MSG

    link_to 'Delete', destroy_unreferenced_taxa_path(taxon), method: :delete,
      class: "btn-warning", data: { confirm: message }
  end

  def confirm_before_superadmin_delete_button taxon
    return if taxon.is_a? Family
    return unless user_is_superadmin?
    link_to append_superadmin_icon("Delete..."), confirm_before_delete_taxa_path(taxon), class: "btn-warning"
  end
end
