# frozen_string_literal: true

module Editors
  class CatalogPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers

    attr_private_initialize :taxon

    def taxa_with_same_name
      @_taxa_with_same_name ||= Taxon.where(name_cache: taxon.name_cache).where.not(id: taxon.id)
    end

    def edit_taxon_button
      link_to "Edit", edit_taxon_path(taxon), class: "btn-default"
    end

    def add_child_button
      rank_to_create = case taxon
                       when Family     then Rank::SUBFAMILY
                       when Subfamily  then Rank::GENUS
                       when Tribe      then Rank::GENUS
                       when Genus      then Rank::SPECIES
                       when Subgenus   then Rank::SPECIES
                       when Species    then Rank::SUBSPECIES
                       when Subspecies then Rank::INFRASUBSPECIES
                       end
      return unless rank_to_create

      link_to "Add #{rank_to_create.downcase}",
        new_taxon_path(rank_to_create: rank_to_create, parent_id: taxon.id), class: "btn-default"
    end

    def add_tribe_button
      return unless taxon.is_a?(Subfamily)
      link_to "Add tribe", new_taxon_path(rank_to_create: Rank::TRIBE, parent_id: taxon.id), class: "btn-default"
    end

    def add_subgenus_button
      return unless taxon.is_a?(Genus)
      link_to "Add subgenus", new_taxon_path(rank_to_create: Rank::SUBGENUS, parent_id: taxon.id), class: "btn-default"
    end

    def convert_to_subspecies_button
      return unless taxon.is_a?(Species)
      link_to 'Convert to subspecies', new_taxon_convert_to_subspecies_path(taxon), class: "btn-default"
    end

    def elevate_to_species_button
      return unless taxon.is_a?(Subspecies)

      link_to 'Elevate to species', taxon_elevate_to_species_path(taxon),
        method: :post, class: "btn-danger",
        data: { confirm: "Are you sure you want to elevate this subspecies to species?" }
    end

    def delete_unreferenced_taxon_button
      return if taxon.is_a?(Family) || taxon.what_links_here.any_columns?

      link_to 'Delete', taxon_path(taxon), method: :delete, class: "btn-danger",
        data: { confirm: 'Are you sure?' }
    end
  end
end
