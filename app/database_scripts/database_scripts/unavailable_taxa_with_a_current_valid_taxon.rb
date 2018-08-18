module DatabaseScripts
  class UnavailableTaxaWithACurrentValidTaxon < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE).where.not(current_valid_taxon: nil)
    end
  end
end

__END__
tags: [regression-test, validated]
topic_areas: [catalog]
