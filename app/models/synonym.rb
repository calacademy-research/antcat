# coding: UTF-8
class Synonym < ActiveRecord::Base
  belongs_to :junior_synonym, class_name: 'Taxon'; validates :junior_synonym, presence: true
  belongs_to :senior_synonym, class_name: 'Taxon' # in the process of fixing up, an incomplete Synonym can be created

  has_paper_trail

  def self.find_or_create junior, senior
    synonyms = Synonym.where junior_synonym_id: junior, senior_synonym_id: senior
    return synonyms.first unless synonyms.empty?
    Synonym.create! junior_synonym: junior, senior_synonym: senior
  end

end
