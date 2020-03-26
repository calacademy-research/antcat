module Editors
  class CatalogPresenter
    include Rails.application.routes.url_helpers
    include ActionView::Helpers

    def initialize taxon
      @taxon = taxon
    end

    def taxa_with_same_name
      @taxa_with_same_name ||= Taxon.where(name_cache: taxon.name_cache).where.not(id: taxon.id)
    end

    def edit_taxon_button
      link_to "Edit", edit_taxa_path(taxon), class: "btn-normal"
    end

    def add_child_button
      rank_to_create = case taxon
                       when Family     then "Subfamily"
                       when Subfamily  then "Genus"
                       when Tribe      then "Genus"
                       when Genus      then "Species"
                       when Subgenus   then "Species"
                       when Species    then "Subspecies"
                       when Subspecies then "Infrasubspecies"
                       end
      return unless rank_to_create

      link_to "Add #{rank_to_create.downcase}",
        new_taxa_path(rank_to_create: rank_to_create, parent_id: taxon.id), class: "btn-normal"
    end

    def add_tribe_button
      return unless taxon.is_a?(Subfamily)
      link_to "Add tribe", new_taxa_path(rank_to_create: 'Tribe', parent_id: taxon.id), class: "btn-normal"
    end

    def add_subgenus_button
      return unless taxon.is_a?(Genus)
      link_to "Add subgenus", new_taxa_path(rank_to_create: 'Subgenus', parent_id: taxon.id), class: "btn-normal"
    end

    def convert_to_subspecies_button
      return unless taxon.is_a? Species
      link_to 'Convert to subspecies', new_taxa_convert_to_subspecies_path(taxon), class: "btn-normal"
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
        data: { confirm: 'Are you sure?' }
    end

    private

      attr_reader :taxon
  end
end
