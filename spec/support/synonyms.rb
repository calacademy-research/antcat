# Used to live in the Taxon model, which is why this monkey patch is
# applied like this: `taxon.extend TaxonSynonymsMonkeyPatch`.

module TaxonSynonymsMonkeyPatch
  def become_junior_synonym_of senior
    Synonym.where(junior_synonym: senior, senior_synonym: self).destroy_all
    Synonym.where(senior_synonym: senior, junior_synonym: self).destroy_all
    Synonym.create! junior_synonym: self, senior_synonym: senior
    senior.update_attributes! status: 'valid'
    update_attributes! status: 'synonym'
  end

  def become_not_junior_synonym_of senior
    Synonym.where(junior_synonym: self, senior_synonym: senior).destroy_all
    update_attributes! status: 'valid' if senior_synonyms.empty?
  end
end
