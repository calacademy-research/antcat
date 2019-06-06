module DatabaseScripts
  class OrphanedProtonyms < DatabaseScript
    def results
      Protonym.where.not(id: Taxon.select(:protonym_id))
    end
  end
end

__END__
description: >
  These can be deleted via script (see %github430).

tags: [regression-test]
topic_areas: [protonyms]
