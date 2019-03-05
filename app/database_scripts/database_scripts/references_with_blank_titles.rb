module DatabaseScripts
  class ReferencesWithBlankTitles < DatabaseScript
    def results
      Reference.where(title: ["", nil])
    end
  end
end

__END__
tags: [regression-test, validated]
topic_areas: [references]
