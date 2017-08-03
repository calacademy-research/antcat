class DatabaseScripts::Scripts::DuplicatedSynonyms
  include DatabaseScripts::DatabaseScript

  def results
    duplicates = []

    synonyms = Synonym.all.to_a
    synonyms.each do |synonym, i|
      next unless synonym
      Synonym.where("junior_synonym_id = ?", synonym.junior_synonym_id)
        .where("senior_synonym_id = ?", synonym.senior_synonym_id)
        .where("id != ?", synonym.id)
        .each do |duplicate|
          index = synonyms.index(duplicate)
          duplicates << duplicate
          synonyms[index] = nil
        end
    end

    duplicates
  end

  def render
    as_table do
      header :synonym, :taxon, :status
      rows do |synonym|
        taxon = synonym.junior_synonym
        [ synonym_link(synonym), markdown_taxon_link(taxon), taxon.status ]
      end
    end
  end

  private
    def synonym_link synonym
      "<a href='/synonyms/#{synonym.id}'>#{synonym.id}</a>"
    end
end

__END__
description: >
  Based on [this script](https://github.com/calacademy-research/antcat/blob/0b1930a3e161e756e3c785bd32d6e54867cc480c/lib/dedupe_synonyms.rb),
  which destroys all synonyms listed here.
topic_areas: [catalog]
