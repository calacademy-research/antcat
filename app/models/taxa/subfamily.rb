# coding: UTF-8
class Subfamily < Taxon
  belongs_to :family
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names,
           -> { where(status: 'collective group name') },
            class_name: 'Genus'

  def add_antweb_attributes attributes
    attributes.merge subfamily: name.to_s
  end

  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

end
