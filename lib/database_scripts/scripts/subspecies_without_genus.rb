class DatabaseScripts::Scripts::SubspeciesWithoutGenus
  include DatabaseScripts::DatabaseScript

  def results
    Subspecies.where(genus: nil)
  end
end

__END__
tags: [regression-test]
topic_areas: [catalog]
