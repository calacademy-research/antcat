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
