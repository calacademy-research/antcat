# coding: UTF-8
class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus
  has_many :subspecies
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

  def siblings
    genus.species
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym] if data[:protonym]
      raise NoProtonymError unless protonym

      # are we importing a species or a subspecies?

      # does it have "Current subspecies:" in its history?
      has_current_subspecies_in_history = false
      for item in data[:raw_history] or []
        if item[:subspecies]
          has_current_subspecies_in_history = true
          break
        end
      end
      if has_current_subspecies_in_history
        klass = Species
      else
        # is the protonym for a subspecies?
        if protonym.name.kind_of? SubspeciesName
          klass = Subspecies
        else
          klass = Species
        end
      end

      if klass == Species
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

      species = klass.create! attributes

      if species.kind_of? Subspecies
        SpeciesEpithetReference.create!(
          fixee:            species,
          fixee_table:      'taxa',
          fixee_attribute: 'species_id',
          genus:            data[:genus],
          epithet:          data[:protonym][:species_epithet],
        )
      end

      (data[:history] || []).each do |item|
        species.taxonomic_history_items.create! taxt: item
      end
      set_status_from_history species, data[:raw_history]

      species
    end
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
    end
  end

  class NoProtonymError < StandardError; end
end
