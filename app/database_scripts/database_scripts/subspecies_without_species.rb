module DatabaseScripts
  class SubspeciesWithoutSpecies < DatabaseScript
    def results
      Subspecies.where(species: nil)
    end
  end
end

__END__
topic_areas: [catalog]
tags: [high-priority]
issue_description: This subspecies has no species.
