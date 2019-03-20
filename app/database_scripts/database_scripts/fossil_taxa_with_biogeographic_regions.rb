module DatabaseScripts
  class FossilTaxaWithBiogeographicRegions < DatabaseScript
    def results
      Taxon.where(fossil: true).where.not(biogeographic_region: [nil, ""])
    end
  end
end

__END__
description: See %github389.
topic_areas: [catalog]
issue_description: This taxon is fossil, but is has a biogeographic region.
