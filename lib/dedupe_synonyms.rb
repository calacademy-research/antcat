# I believe this is a database maintenance script that must be called manually.
# Possibly not used any longer.
# TODO? make callable from rake task
# See also `DatabaseScripts::Scripts::DuplicatedSynonyms`.

module DedupeSynonyms
  def self.dedupe
    duplicate_count = 0
    synonyms = Synonym.all.to_a
    synonyms.each do |synonym, i|
      next unless synonym
      Synonym.where("junior_synonym_id = ?", synonym.junior_synonym_id)
        .where("senior_synonym_id = ?", synonym.senior_synonym_id)
        .where("id != ?", synonym.id)
        .each do |duplicate|
          duplicate_count += 1
          index = synonyms.index(duplicate)
          duplicate.destroy
          synonyms[index] = nil
        end
    end
  end
end
