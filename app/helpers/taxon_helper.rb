module TaxonHelper
  def sort_by_status_and_name taxa
    taxa.sort do |a, b|
      if a.status == b.status
        # name ascending
        a.name.name <=> b.name.name
      else
        # status descending
        b.status <=> a.status
      end
    end
  end

  def convert_to_subspecies_button taxon
    return unless taxon.kind_of? Species

    link_to 'Convert to subspecies', new_taxa_convert_to_subspecies_path(taxon),
    class: "btn-new"
  end

  def elevate_to_species_button taxon
    return unless taxon.kind_of? Subspecies

    link_to 'Elevate to species', elevate_to_species_taxa_path(taxon),
      method: :put, class: "btn-new", data: { confirm: <<-MSG.squish }
        Are you sure you want to elevate this subspecies to species?
      MSG
  end

  def delete_unreferenced_taxon_button taxon
    return unless taxon.nontaxt_references.empty? # TODO check taxt references

    link_to 'Delete', destroy_unreferenced_taxa_path(taxon), method: :delete,
      class: "btn-delete", data: { confirm: <<-MSG.squish }
        Are you sure you want to delete this taxon? Note: It may take a few
        moments to check that this taxon isn't being referenced.
      MSG
  end
end
