class DatabaseScripts::Scripts::LocalityButNoBiogeographicRegion
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.ranks(Species, Subspecies)
      .where(biogeographic_region: ["", nil])
      .where.not(verbatim_type_locality: ["", nil])
  end

  def render
    as_table do
      header :taxon, :verbatim_type_locality

      rows do |taxon|
        [ markdown_taxon_link(taxon), taxon.verbatim_type_locality ]
      end
    end
  end
end

__END__
topic_areas: [catalog]
