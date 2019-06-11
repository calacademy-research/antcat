module Taxa::Synonyms
  extend ActiveSupport::Concern

  def current_valid_taxon_including_synonyms
    @current_valid_taxon_including_synonyms ||= Taxa::CurrentValidTaxonIncludingSynonyms[self]
  end

  def junior_synonyms_with_own_id
    junior_synonyms_objects.joins(:junior_synonym).select('synonyms.id, taxa.id AS taxon_id')
  end

  def senior_synonyms_with_own_id
    senior_synonyms_objects.joins(:senior_synonym).select('synonyms.id, taxa.id AS taxon_id')
  end
end
