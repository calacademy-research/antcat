class FixDupeSynonyms < ActiveRecord::Migration
  def up
    synonyms = Synonym.where junior_synonym_id: 440501, senior_synonym_id: 440792
    return unless synonyms.size == 2
    synonyms.first.destroy
  end

  def down
  end
end
