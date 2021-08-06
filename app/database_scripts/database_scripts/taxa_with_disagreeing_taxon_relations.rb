# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithDisagreeingTaxonRelations < DatabaseScript
    def empty?
      !(
        # subfamily_id.
        subfamily_id_of_subtribe_vs_tribe.exists? ||
        subfamily_id_of_genus_vs_tribe.exists? ||
        subfamily_id_of_subgenus_vs_genus.exists? ||
        subfamily_id_of_species_vs_genus.exists? ||
        subfamily_id_of_subspecies_vs_species.exists? ||
        subfamily_id_of_infrasubspecies_vs_subspecies.exists? ||

        # genus_id.
        genus_id_of_species_vs_subgenus.exists? ||
        genus_id_of_subspecies_vs_species.exists? ||
        genus_id_of_infrasubspecies_vs_subspecies.exists? ||

        # species_id.
        species_id_of_infrasubspecies_vs_subspecies.exists?
      )
    end

    # subfamily_id.
    def subfamily_id_of_subtribe_vs_tribe
      Subtribe.joins(:tribe).where("tribes_taxa.subfamily_id != taxa.subfamily_id")
    end

    def subfamily_id_of_genus_vs_tribe
      Genus.joins(:tribe).where("tribes_taxa.subfamily_id != taxa.subfamily_id")
    end

    def subfamily_id_of_subgenus_vs_genus
      Subgenus.joins(:genus).where("genera_taxa.subfamily_id != taxa.subfamily_id")
    end

    def subfamily_id_of_species_vs_genus
      Species.joins(:genus).where("genera_taxa.subfamily_id != taxa.subfamily_id")
    end

    def subfamily_id_of_subspecies_vs_species
      Subspecies.joins(:species).where("species_taxa.subfamily_id != taxa.subfamily_id")
    end

    def subfamily_id_of_infrasubspecies_vs_subspecies
      Infrasubspecies.joins(:subspecies).where("subspecies_taxa.subfamily_id != taxa.subfamily_id")
    end

    # genus_id.
    def genus_id_of_species_vs_subgenus
      Species.joins(:subgenus).where("subgenera_taxa.genus_id != taxa.genus_id")
    end

    def genus_id_of_subspecies_vs_species
      Subspecies.joins(:species).where("species_taxa.genus_id != taxa.genus_id")
    end

    def genus_id_of_infrasubspecies_vs_subspecies
      Infrasubspecies.joins(:subspecies).where("subspecies_taxa.genus_id != taxa.genus_id")
    end

    # species_id.
    def species_id_of_infrasubspecies_vs_subspecies
      Infrasubspecies.joins(:subspecies).where("subspecies_taxa.species_id != taxa.species_id")
    end

    def render
      # subfamily_id.
      render_table(subfamily_id_of_subtribe_vs_tribe, "subtribe", :subfamily, :tribe) +
        render_table(subfamily_id_of_genus_vs_tribe, "genus", :subfamily, :tribe) +
        render_table(subfamily_id_of_subgenus_vs_genus, "subgenus", :subfamily, :genus) +
        render_table(subfamily_id_of_species_vs_genus, "species", :subfamily, :genus) +
        render_table(subfamily_id_of_subspecies_vs_species, "subspecies", :subfamily, :species) +
        render_table(subfamily_id_of_infrasubspecies_vs_subspecies, "infrasubspecies", :subfamily, :subspecies) +

        # genus_id.
        render_table(genus_id_of_species_vs_subgenus, "species", :genus, :subgenus) +
        render_table(genus_id_of_subspecies_vs_species, "subspecies", :genus, :species) +
        render_table(genus_id_of_infrasubspecies_vs_subspecies, "infrasubspecies", :genus, :subspecies) +

        # species_id.
        render_table(species_id_of_infrasubspecies_vs_subspecies, "infrasubspecies", :species, :subspecies)
    end

    def render_table table_results, disagreeing_rank, taxon_method, of_its_rank
      as_table do |t|
        t.caption "#{taxon_method.upcase} mismatch: #{disagreeing_rank} vs. #{of_its_rank}"
        t.header 'Disagreeing taxon', '...', '...', '...', 'Disagrees with taxon'

        t.rows(table_results) do |disagreeing_taxon|
          disagreeing_taxon_taxon = disagreeing_taxon.public_send(taxon_method)

          disagrees_with_taxon = disagreeing_taxon.public_send(of_its_rank)
          disagrees_with_taxon_taxon = disagrees_with_taxon.public_send(taxon_method)

          [
            taxon_link(disagreeing_taxon) + '<br><br>',
            "#{taxon_method} of #{disagreeing_rank}" + '<br>' + bold_warning(disagreeing_taxon_taxon.name_cache),
            "...does not match...<br><br>",
            "#{taxon_method} of its #{of_its_rank}" + '<br>' + bold_warning(disagrees_with_taxon_taxon.name_cache),
            taxon_link(disagrees_with_taxon)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
tags: [disagreeing-data, taxa]

issue_description:

description: >

related_scripts:
  - TaxaWithDisagreeingNameParts
  - TaxaWithDisagreeingTaxonRelations
