module DatabaseScripts
  class ProtonymsWithMoreThanOneOriginalCombination < DatabaseScript
    def results
      Protonym.joins(:taxa).where(taxa: { original_combination: true }).group(:protonym_id).having('COUNT(taxa.id) > 1')
    end
  end
end

__END__

description: >
  Where "protonym" means `Protonym` record, and "original combination" means `Taxon` record where `original_combination` is true.

tags: []
topic_areas: [protonyms]
