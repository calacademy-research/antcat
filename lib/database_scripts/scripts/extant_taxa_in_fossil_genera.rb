class DatabaseScripts::Scripts::ExtantTaxaInFossilGenera
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.extant.ranks(Species, Subspecies)
      .self_join_on(:genus)
      .where(taxa_self_join_alias: { fossil: true })
  end

  def render
    as_table do
      header :species_or_subspecies, :status, :genus, :genus_status

      rows do |taxon|
        [ markdown_taxon_link(taxon),
          taxon.status,
          markdown_taxon_link(taxon.genus),
          taxon.genus.status  ]
      end
    end
  end
end

__END__
topic_areas: [catalog]
