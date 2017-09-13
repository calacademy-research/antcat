module DatabaseScripts
  class LocalityButNoBiogeographicRegion < DatabaseScript
    def results
      Taxon.ranks(Species, Subspecies)
        .where(biogeographic_region: ["", nil])
        .where.not(verbatim_type_locality: ["", nil])
    end

    def render
      as_table do |t|
        t.header :taxon, :verbatim_type_locality

        t.rows do |taxon|
          [ markdown_taxon_link(taxon), taxon.verbatim_type_locality ]
        end
      end
    end
  end
end

__END__
topic_areas: [types]
