class DatabaseScripts::Scripts::SubspeciesWithoutSpecies
  include DatabaseScripts::DatabaseScript

  def results
    Subspecies.where(species: nil, auto_generated: false)
  end
end

__END__
description: Auto-generated subspecies are not included.
topic_areas: [catalog]
