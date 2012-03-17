# coding: UTF-8
class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, order: :name
  has_many :subspecies, order: :name
  has_many :subgenera, order: :name

  scope :without_subfamily, where(subfamily_id: nil).order(:name)
  scope :without_tribe, where(tribe_id: nil)

  def children
    species
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def full_name
    name
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera ||
    subfamily && subfamily.genera.without_tribe.all ||
    Genus.without_subfamily.all
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]

      headline_notes_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        subfamily: data[:subfamily],
        tribe: data[:tribe],
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
      genus = create! attributes
      data[:taxonomic_history].each do |item|
        genus.taxonomic_history_items.create! taxt: item
      end

      type_species = data[:type_species]
      if type_species
        target_name = type_species[:genus_name]
        target_name << ' (' << type_species[:subgenus_epithet] + ')' if type_species[:subgenus_epithet]
        target_name << ' '  << type_species[:species_epithet]
        ForwardReference.create! source_id: genus.id, target_name: target_name, fossil: type_species[:fossil]
      end

      genus
    end
  end

  def self.create_from_fixup attributes
    name = attributes[:name]
    fossil = attributes[:fossil] || false
    subfamily_id = attributes[:subfamily_id]
    tribe_id = attributes[:tribe_id]
    subfamily_id = Tribe.find(tribe_id).subfamily_id if tribe_id.present?

    genus_group = Taxon.find_genus_group_by_name name
    if genus_group
      genus_group.update_attribute :tribe_id, tribe_id
      Progress.log "FIXUP updated tribe for #{genus_group.type} #{genus_group.full_name}"
    else
      genus_group = Genus.create! name: name, status: 'valid', fossil: fossil, subfamily_id: subfamily_id,
        tribe_id: tribe_id
      Progress.log "FIXUP created genus #{genus_group.full_name}"
    end

    genus_group
  end

end
