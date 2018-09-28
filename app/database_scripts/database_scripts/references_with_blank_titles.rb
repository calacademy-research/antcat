module DatabaseScripts
  class ReferencesWithBlankTitles < DatabaseScript
    def results
      Reference.where(title: ["", nil])
    end
  end
end

__END__
tags: [validated]
topic_areas: [references]
