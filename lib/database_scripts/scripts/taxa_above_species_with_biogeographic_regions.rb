class DatabaseScripts::Scripts::TaxaAboveSpeciesWithBiogeographicRegions
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.exclude_ranks(Species, Subspecies)
      .where.not(biogeographic_region: ["", nil])
  end

  def render
    as_table do
      header :subspecies, :biogeographic_region
      rows { |taxon| [ markdown_taxon_link(taxon), taxon.biogeographic_region ] }
    end
  end
end

__END__
topic_areas: [catalog]
