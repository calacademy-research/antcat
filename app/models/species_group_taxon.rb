# coding: UTF-8
class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def statistics
    get_statistics [:subspecies]
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym] if data[:protonym]
      raise NoProtonymError unless protonym
      get_taxon_class(protonym, data[:raw_history]).import_data protonym, data
    end
  end

  def self.get_taxon_class_from_history history
    for item in history or []
      return Subspecies if item[:currently_subspecies_of]
      return Species if item[:subspecies]
    end
    for item in history or []
      return Species if item[:raised_to_species]
    end
    nil
  end

  def self.get_taxon_class_from_protonym protonym
    protonym.name.kind_of?(SubspeciesName) ? Subspecies : Species
  end

  def self.get_taxon_class protonym, history
    get_taxon_class_from_history(history) || get_taxon_class_from_protonym(protonym)
  end

  def self.import_data protonym, data
    if self == Species
      name = Name.import data
    else
      name = Name.import data[:protonym].merge genus: data[:genus]
    end

    attributes = {
      genus:      data[:genus],
      name:       name,
      fossil:     data[:fossil] || false,
      status:     data[:status] || 'valid',
      protonym:   protonym,
    }

    species = create! attributes

    if species.kind_of? Subspecies
      target_epithet = get_currently_subspecies_of_from_history data[:raw_history]
      target_epithet ||=  data[:protonym][:species_epithet]
      SpeciesEpithetReference.create!(
        fixee:            species,
        fixee_table:      'taxa',
        fixee_attribute: 'species_id',
        genus:            data[:genus],
        epithet:          target_epithet,
      )
    end

    (data[:history] || []).each do |item|
      species.taxonomic_history_items.create! taxt: item
    end
    set_status_from_history species, data[:raw_history]

    species
  end

  def self.set_status_from_history species, history
    return unless history.present?

    species.update_attributes status: 'valid'

    genus = species.genus

    for item in history
      if item[:synonym_ofs]
        for synonym_of in item[:synonym_ofs]
          name = Name.import synonym_of.merge(genus: genus)
          senior = Species.find_by_name name.name
          if senior
            species.update_attributes status: 'synonym', synonym_of: senior
          else
            ForwardReference.create! fixee: species, fixee_attribute: 'synonym_of', name: name
          end
        end
      end
      if item[:homonym_of]
        species.update_attributes status: 'homonym'
      end
    end
  end

  def self.get_currently_subspecies_of_from_history history
    for item in history or []
      if item[:currently_subspecies_of]
        return item[:currently_subspecies_of][:species][:species_epithet]
      end
    end
    nil
  end

  class NoProtonymError < StandardError; end
end
