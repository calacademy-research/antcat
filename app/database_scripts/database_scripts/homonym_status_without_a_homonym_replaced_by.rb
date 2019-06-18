module DatabaseScripts
  class HomonymStatusWithoutAHomonymReplacedBy < DatabaseScript
    def results
      Taxon.where(status: Status::HOMONYM).where(homonym_replaced_by: nil)
    end
  end
end

__END__

tags: []
topic_areas: [homonyms]
