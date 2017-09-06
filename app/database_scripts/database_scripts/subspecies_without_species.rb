module DatabaseScripts
  class SubspeciesWithoutSpecies < DatabaseScript
    def results
      Subspecies.where(species: nil, auto_generated: false)
    end
  end
end

__END__
description: Auto-generated subspecies are not included.
topic_areas: [catalog]
