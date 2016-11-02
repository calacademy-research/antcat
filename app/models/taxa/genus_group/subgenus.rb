class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  has_many :species
  attr_accessible :subfamily, :tribe, :genus, :homonym_replaced_by

  def parent
    genus
  end

  def statistics valid_only: false; end
end
