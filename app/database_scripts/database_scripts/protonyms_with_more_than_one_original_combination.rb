module DatabaseScripts
  class ProtonymsWithMoreThanOneOriginalCombination < DatabaseScript
    def results
      Protonym.joins(:taxa).where(taxa: { status: Status::ORIGINAL_COMBINATION }).group(:protonym_id).having('COUNT(taxa.id) > 1')
    end
  end
end

__END__

description: >
  Where "protonym" means `Protonym` record, and "original combination" means `Taxon` record with the status `original combination`.

tags: [new!]
topic_areas: [protonyms]
