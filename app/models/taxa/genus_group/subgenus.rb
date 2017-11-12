class Subgenus < GenusGroupTaxon
  belongs_to :genus

  # No taxa have a `subgenus_id` as of 2016.
  has_many :species

  validates_presence_of :genus

  def parent
    genus
  end

  def statistics valid_only: false; end
end
