# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithDisagreeingNameParts < DatabaseScript
    def empty?
      !(
        # Genus part.
        genus_part_of_species_vs_genus.exists? ||
        genus_part_of_subspecies_vs_species.exists? ||
        genus_part_of_infrasubspecies_vs_species.exists? ||

        # Species part.
        species_part_of_subspecies_vs_species.exists? ||
        species_part_of_infrasubspecies_vs_subspecies.exists? ||

        # Subspecies part.
        subspecies_part_of_infrasubspecies_vs_subspecies.exists?
      )
    end

    # Genus part.
    def genus_part_of_species_vs_genus
      Species.joins(:name).joins(:genus).
        joins("JOIN names genus_names ON genus_names.id = genera_taxa.name_id").
        where("SUBSTRING_INDEX(names.name, ' ', 1) != genus_names.name")
    end

    def genus_part_of_subspecies_vs_species
      Subspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(names.name, ' ', 1) !=
          SUBSTRING_INDEX(species_names.name, ' ', 1)
        SQL
    end

    def genus_part_of_infrasubspecies_vs_species
      Infrasubspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(names.name, ' ', 1) !=
          SUBSTRING_INDEX(species_names.name, ' ', 1)
        SQL
    end

    # Species part.
    def species_part_of_subspecies_vs_species
      Subspecies.joins(:name).joins(:species).
        joins("JOIN names species_names ON species_names.id = species_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(species_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def species_part_of_infrasubspecies_vs_subspecies
      Infrasubspecies.joins(:name).joins(:subspecies).
        joins("JOIN names subspecies_names ON subspecies_names.id = subspecies_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(subspecies_names.name, ' ', 2), ' ', -1)
        SQL
    end

    # Subspecies part.
    def subspecies_part_of_infrasubspecies_vs_subspecies
      Infrasubspecies.joins(:name).joins(:subspecies).
        joins("JOIN names subspecies_names ON subspecies_names.id = subspecies_taxa.name_id").
        where(<<~SQL.squish)
          SUBSTRING_INDEX(SUBSTRING_INDEX(names.name, ' ', 2), ' ', -1) !=
          SUBSTRING_INDEX(SUBSTRING_INDEX(subspecies_names.name, ' ', 2), ' ', -1)
        SQL
    end

    def render
      # Genus part.
      render_table(genus_part_of_species_vs_genus, "species", :genus_epithet, :genus) +
        render_table(genus_part_of_subspecies_vs_species, "subspecies", :genus_epithet, :species) +
        render_table(genus_part_of_infrasubspecies_vs_species, "infrasubspecies", :genus_epithet, :species) +

        # Subspecies part.
        render_table(species_part_of_subspecies_vs_species, "subspecies", :species_epithet, :species) +
        render_table(species_part_of_infrasubspecies_vs_subspecies, "infrasubspecies", :species_epithet, :subspecies) +

        # Subspecies part.
        render_table(subspecies_part_of_infrasubspecies_vs_subspecies, "infrasubspecies", :subspecies_epithet, :subspecies)
    end

    def render_table table_results, disagreeing_rank, epithet_method, of_its_rank
      as_table do |t|
        humanized_epithet = epithet_method.to_s.humanize.downcase

        t.caption "#{humanized_epithet.upcase} mismatch: #{disagreeing_rank} vs. #{of_its_rank}"
        t.header 'Disagreeing taxon', '...', '...', '...', 'Disagrees with taxon'
        t.rows(table_results) do |taxon|
          disagreeing_name_part = taxon.name.public_send(epithet_method)

          disagrees_with_taxon = taxon.public_send(of_its_rank)
          disagrees_with_name_part = disagrees_with_taxon.name.public_send(epithet_method)

          [
            taxon_link(taxon) + '<br><br>',
            "#{humanized_epithet} of #{disagreeing_rank}" + '<br>' + bold_warning(disagreeing_name_part),
            "...does not match...<br><br>",
            "#{humanized_epithet} of its #{of_its_rank}" + '<br>' + bold_warning(disagrees_with_name_part),
            taxon_link(disagrees_with_taxon)
          ]
        end
      end
    end
  end
end

__END__

section: regression-test
category: Catalog
tags: []

issue_description:

description: >

related_scripts:
  - TaxaWithDisagreeingNameParts
