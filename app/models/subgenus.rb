# coding: UTF-8
class Subgenus < Taxon
  belongs_to :genus
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name
  validates_presence_of :genus

  def children
    species
  end

  def statistics
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]

      headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        genus: data[:genus],
        name: data[:name],
        fossil: data[:fossil] || false,
        status: data[:status] || 'valid',
        synonym_of: data[:synonym_of],
        protonym: protonym,
        headline_notes_taxt: headline_notes_taxt,
      }
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        type_species_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
        attributes[:type_taxon_taxt] = type_species_taxt
      end
      subgenus = create! attributes
      data[:taxonomic_history].each do |item|
        subgenus.taxonomic_history_items.create! taxt: item
      end

      type_species = data[:type_species]
      if type_species
        target_name = type_species[:subgenus_name] || type_species[:genus_name]
        target_name << ' (' << type_species[:subgenus_epithet] + ')' if type_species[:subgenus_epithet]
        target_name << ' '  << type_species[:species_epithet]
        ForwardReference.create! source_id: subgenus.id, target_name: target_name,
          fossil: type_species[:fossil]
      end

      subgenus
    end
  end

end
