# coding: UTF-8
class Subfamily < Taxon
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies

  def self.import data
    transaction do
      attributes = {
        name:  Name.import(data),
        fossil:       data[:fossil] || false,
        status:       'valid',
        protonym:     Protonym.import(data[:protonym]),
      }
      attributes.merge! get_type_attributes :type_genus, data
      subfamily = create! attributes
      data[:taxonomic_history].each do |item|
        subfamily.taxonomic_history_items.create! taxt: item
      end
      subfamily
    end
  end

  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

end
