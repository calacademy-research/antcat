module DatabaseScripts
  class ObsoleteCombinationsWithSameNameAsProtonym < DatabaseScript
    def results
      Taxon.joins(:name, protonym: :name).
        where(status: Status::OBSOLETE_COMBINATION).
        where.not(original_combination: true).
        where("names.name = names_protonyms.name")
    end
  end
end

__END__

description: >
  Taxa where `original_combination` is checked are not included.

topic_areas: [catalog]
