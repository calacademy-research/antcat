module Editors
  class TaxonViewObject < ViewObject
    def initialize taxon
      @taxon = taxon
    end

    def taxa_with_same_name
      @taxa_with_same_name ||= Taxon.where(name_cache: taxon.name_cache).where.not(id: taxon.id)
    end

    def default_name_string
      return unless taxon.is_a?(SpeciesGroupTaxon) || taxon.is_a?(Subgenus)
      return taxon.species.name.name + ' ' if taxon.is_a?(Subspecies)
      return taxon.subspecies.name.name + ' ' if taxon.is_a?(Infrasubspecies)
      taxon.genus.name.name + ' '
    end

    def link_to_edit_taxon
      link_to "Edit", edit_taxa_path(taxon), class: "btn-normal"
    end

    def link_to_review_change
      return unless taxon.waiting? && taxon.last_change
      link_to 'Review change', "/changes/#{taxon.last_change.id}", class: "btn-tiny btn-normal"
    end

    def add_child_button
      child_ranks = { family:     "subfamily",
                      subfamily:  "genus",
                      tribe:      "genus",
                      genus:      "species",
                      subgenus:   "species",
                      species:    "subspecies",
                      subspecies: "infrasubspecies" }

      rank_to_add = child_ranks[taxon.rank.to_sym]
      return if rank_to_add.blank?

      url = new_taxa_path rank_to_create: rank_to_add, parent_id: taxon.id
      link_to "Add #{rank_to_add}", url, class: "btn-normal"
    end

    def add_tribe_button
      return unless taxon.is_a?(Subfamily)

      url = new_taxa_path rank_to_create: 'tribe', parent_id: taxon.id
      link_to "Add tribe", url, class: "btn-normal"
    end

    def add_subgenus_button
      return unless taxon.is_a?(Genus)

      url = new_taxa_path rank_to_create: 'subgenus', parent_id: taxon.id
      link_to "Add subgenus", url, class: "btn-normal"
    end

    def convert_to_subspecies_button
      return unless taxon.is_a? Species

      url = new_taxa_convert_to_subspecies_path taxon
      link_to 'Convert to subspecies', url, class: "btn-normal"
    end

    def elevate_to_species_button
      return unless taxon.is_a? Subspecies

      link_to 'Elevate to species', taxa_elevate_to_species_path(taxon),
        method: :post, class: "btn-warning",
        data: { confirm: "Are you sure you want to elevate this subspecies to species?" }
    end

    def delete_unreferenced_taxon_button
      return if taxon.is_a?(Family) || taxon.what_links_here.any_columns?

      link_to 'Delete', taxa_path(taxon), method: :delete, class: "btn-warning",
        data: { confirm_with_edit_summary: true }
    end

    private

      attr_reader :taxon
  end
end
