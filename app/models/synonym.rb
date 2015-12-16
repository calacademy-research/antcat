# coding: UTF-8
class Synonym < ActiveRecord::Base
  include UndoTracker

  attr_accessible :senior_synonym, :junior_synonym,:senior_synonym_id, :junior_synonym_id

  belongs_to :junior_synonym, class_name: 'Taxon'
  validates :junior_synonym, presence: true
  belongs_to :senior_synonym, class_name: 'Taxon' # in the process of fixing up, an incomplete Synonym can be created
  has_paper_trail meta: { change_id: :get_current_change_id }

  def self.invalid_senior_synonyms
    Synonym.all.select do |synonymy|
      synonymy.senior_synonym.invalid?
    end
  end

  def self.find_or_create junior, senior
    synonyms = Synonym.where junior_synonym_id: junior, senior_synonym_id: senior
    return synonyms.first unless synonyms.empty?
    Synonym.create! junior_synonym: junior, senior_synonym: senior
  end

end
