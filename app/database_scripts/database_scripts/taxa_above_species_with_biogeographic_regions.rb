module DatabaseScripts
  class TaxaAboveSpeciesWithBiogeographicRegions < DatabaseScript
    def results
      Taxon.exclude_ranks(Species, Subspecies).
        where.not(biogeographic_region: ["", nil])
    end

    def render
      as_table do |t|
        t.header :subspecies, :biogeographic_region

        t.rows { |taxon| [markdown_taxon_link(taxon), taxon.biogeographic_region] }
      end
    end
  end
end

__END__
topic_areas: [catalog]
