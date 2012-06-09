# coding: UTF-8
class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  belongs_to :tribe
  has_many :species

  def self.import data
    super data, :subgenus_name, genus: data[:genus]
  end

  def statistics
  end

end
