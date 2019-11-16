module DatabaseScripts
  class UnavailableUncategorizedTaxa < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED)
    end
  end
end

__END__

description: >
  Taxa with the status `unavailable uncategorized`. We want to convert these to other statuses.

tags: [new!]
topic_areas: [catalog]
related_scripts:
  - UnavailableUncategorizedTaxaTouchedByEditors
  - UnavailableUncategorizedTaxa
