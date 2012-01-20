# coding: UTF-8
class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, class_name: 'Species', order: :name
  has_many :subspecies, class_name: 'Subspecies', order: :name
  has_many :subgenera, class_name: 'Subgenus', order: :name

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

      type_taxon_name = nil
      if data[:type_species]
        type_taxon_name = Taxt.encode_taxon_name data[:type_species][:genus_name], :genus, data[:type_species]
      end

      headline_notes_taxt = Bolton::Catalog::TextToTaxt.convert(data[:note])
      attributes = {
        name:data[:name],
        fossil:data[:fossil],
        status:'valid',
        protonym:protonym,
        headline_notes_taxt: headline_notes_taxt,
        type_taxon_name: type_taxon_name
      }
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        type_species_taxt = Bolton::Catalog::TextToTaxt.convert(data[:type_species][:texts])
        attributes[:type_taxon_taxt] = type_species_taxt
      end
      genus = create! attributes
      data[:taxonomic_history].each do |item|
        genus.taxonomic_history_items.create! taxt: item
      end

      if data[:type_species]
        target_name = data[:type_species][:genus_name] + ' ' + data[:type_species][:species_epithet]
        ForwardReference.create! source_id: genus.id, source_attribute: :type_taxon, target_name: target_name,
          fossil: data[:type_species][:fossil]
      end

      genus
    end
  end

end
