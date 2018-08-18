module DatabaseScripts
  class ReferencesWithBlankTitles < DatabaseScript
    def results
      Reference.where(title: ["", nil])
    end
  end
end

__END__
topic_areas: [references, validated]
