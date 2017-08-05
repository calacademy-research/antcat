class DatabaseScripts::Scripts::ValidTaxaWithACurrentValidTaxonId
  include DatabaseScripts::DatabaseScript

  def results
    Taxon.valid.where.not(current_valid_taxon_id: nil)
  end
end

__END__
description: Valid taxa that have a `current_valid_taxon_id`.
topic_areas: [catalog]
