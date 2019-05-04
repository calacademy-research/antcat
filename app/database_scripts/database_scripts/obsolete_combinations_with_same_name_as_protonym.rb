module DatabaseScripts
  class ObsoleteCombinationsWithSameNameAsProtonym < DatabaseScript
    def results
      Taxon.joins(:name, protonym: :name).
        where(status: Status::OBSOLETE_COMBINATION).
        where("names.name = names_protonyms.name")
    end
  end
end

__END__

description: >

tags: [new!]
topic_areas: [catalog]
