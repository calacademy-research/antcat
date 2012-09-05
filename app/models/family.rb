# coding: UTF-8
class Family < Taxon

  def self.import data
    transaction do
      attributes = {
        name:                Name.import(family_name: 'Formicidae'),
        fossil:              false,
        status:              'valid',
        protonym:            Protonym.import(data[:protonym]),
        headline_notes_taxt: Importers::Bolton::Catalog::TextToTaxt.convert(data[:note]),
      }
      attributes.merge! get_type_attributes :type_genus, data
      family = create! attributes
      data[:history].each do |item|
        family.history_items.create! taxt: item
      end
      family
    end
  end

  def genera
    Genus.without_subfamily.ordered_by_name
  end

  def subfamilies
    Subfamily.ordered_by_name
  end

  def statistics
    get_statistics Subfamily, Tribe, Genus, Species, Subspecies
  end

  def get_statistics *ranks
    ranks.inject({}) do |statistics, klass|
      count = klass.count :group => [:fossil, :status]
      self.class.massage_count count, Rank[klass].to_sym(:plural), statistics
      statistics
    end
  end

end
