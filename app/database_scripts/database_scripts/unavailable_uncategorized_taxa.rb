module DatabaseScripts
  class UnavailableUncategorizedTaxa < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED)
    end
  end
end

__END__

category: Catalog
tags: [new!]

description: >
  Taxa with the status `unavailable uncategorized`. We want to convert these to other statuses.

related_scripts:
  - UnavailableUncategorizedTaxaTouchedByEditors
  - UnavailableUncategorizedTaxa
