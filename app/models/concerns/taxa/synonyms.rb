module Taxa::Synonyms
  extend ActiveSupport::Concern

  def current_valid_taxon_including_synonyms
    Taxa::CurrentValidTaxonIncludingSynonyms[self]
  end

  def junior_synonyms_with_own_id
    junior_synonyms_objects.joins(:junior_synonym).select('synonyms.id, taxa.id AS taxon_id')
  end

  def senior_synonyms_with_own_id
    senior_synonyms_objects.joins(:senior_synonym).select('synonyms.id, taxa.id AS taxon_id')
  end

  def junior_synonyms_recursive
    @junior_synonyms_recursive ||= Taxon.where(id: junior_synonym_ids_recursive)
  end

  protected

    # TODO this executes a lot of queries, but let's first clear up some things,
    # see https://github.com/calacademy-research/antcat/issues/279
    def junior_synonym_ids_recursive
      return [] unless junior_synonyms.exists?

      all_juniors = junior_synonyms.pluck(:id)

      junior_synonyms.each do |junior_synonym|
        ids = junior_synonym.junior_synonym_ids_recursive
        all_juniors.push(*ids) unless ids.empty?
      end

      all_juniors
    end
end
