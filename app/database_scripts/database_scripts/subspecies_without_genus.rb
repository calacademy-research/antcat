module DatabaseScripts
  class SubspeciesWithoutGenus < DatabaseScript
    def results
      Subspecies.where(genus: nil)
    end
  end
end

__END__
tags: [regression-test]
topic_areas: [catalog]
