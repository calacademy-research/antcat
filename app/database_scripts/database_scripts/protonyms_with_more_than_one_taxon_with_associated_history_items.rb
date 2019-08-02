module DatabaseScripts
  class ProtonymsWithMoreThanOneTaxonWithAssociatedHistoryItems < DatabaseScript
    def results
      Protonym.distinct.joins(:taxa).
        where(taxa: { id: Taxon.joins(:history_items).select(:id) }).
        group("protonyms.id").having("COUNT(protonyms.id) > 1")
    end
  end
end

__END__

description: >

tags: []
topic_areas: [protonyms]
