class DatabaseScripts::Scripts::ValidTaxaWithNonValidParents
  include DatabaseScripts::DatabaseScript

  def genus_results
    Genus.valid.self_join_on(:subfamily)
      .where.not(taxa_self_join_alias: { status: "valid" })
  end

  def species_results
    Species.valid.self_join_on(:genus)
      .where.not(taxa_self_join_alias: { status: "valid" })
  end

  def subspecies_results
    Subspecies.valid.self_join_on(:species)
      .where.not(taxa_self_join_alias: { status: "valid" })
  end

  def render
    as_table do
      header :genus, :genus_status, :subfamily, :subfamily_status

      rows(genus_results) do |genus|
        [ markdown_taxon_link(genus),
          genus.status,
          markdown_taxon_link(genus.subfamily),
          genus.subfamily.status ]
      end
    end <<

      as_table do
        header :species, :species_status, :genus, :genus_status

        rows(species_results) do |species|
          [ markdown_taxon_link(species),
            species.status,
            markdown_taxon_link(species.genus),
            species.genus.status ]
        end
      end <<

      as_table do
        header :subspecies, :subspecies_status, :species, :species_status

        rows(subspecies_results) do |subspecies|
          [ markdown_taxon_link(subspecies),
            subspecies.status,
            markdown_taxon_link(subspecies.species),
            subspecies.species.status ]
        end
      end
  end
end

__END__
description: >
  Note: Valid species in genera classified as collective group name is not a data
  issue. It has to do with how CGNs are stored in the database, please ignore.

topic_areas: [catalog]
