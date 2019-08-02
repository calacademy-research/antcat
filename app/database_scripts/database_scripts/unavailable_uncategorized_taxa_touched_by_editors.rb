module DatabaseScripts
  class UnavailableUncategorizedTaxaTouchedByEditors < DatabaseScript
    def results
      Taxon.where(status: Status::UNAVAILABLE_UNCATEGORIZED).where(auto_generated: false)
    end
  end
end

__END__

description: >

tags: []
topic_areas: [catalog]
