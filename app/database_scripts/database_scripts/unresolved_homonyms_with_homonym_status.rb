module DatabaseScripts
  class UnresolvedHomonymsWithHomonymStatus < DatabaseScript
    def results
      Taxon.where(unresolved_homonym: true).where(status: Status::HOMONYM)
    end
  end
end

__END__

tags: [regression-test]
topic_areas: [homonyms]
