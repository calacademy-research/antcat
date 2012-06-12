class SubspeciesName < Name

  belongs_to :species_name
  validates :species_name, presence: true

  def self.import data
    return unless data[:subspecies]

    epithet = data[:subspecies].first[:species_group_epithet]
    raise unless data[:genus]

    if data[:species]
      species_name = data[:species].name_object
    else
      species_name = SpeciesName.import data
    end

    name = Name.find_by_species_name_id_and_epithet species_name.id, epithet
    return name if name

    create!({
      name:             genus_group_name.name + ' ' + species_name.name + ' ' + epithet,
      epithet:          epithet,
      genus_group_name: data[:genus],
    })
  end

  def rank
    'species'
  end

end
