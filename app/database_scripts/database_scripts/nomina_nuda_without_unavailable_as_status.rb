module DatabaseScripts
  class NominaNudaWithoutUnavailableAsStatus < DatabaseScript
    def results
      Taxon.where(nomen_nudum: true).where.not(status: Status::UNAVAILABLE)
    end
  end
end

__END__

tags: [regression-test]
topic_areas: [catalog]
