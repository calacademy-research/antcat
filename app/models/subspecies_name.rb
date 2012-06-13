class SubspeciesName < Name

  belongs_to :species_name
  validates :species_name, presence: true

  belongs_to :next_subspecies_name, class_name: 'SubspeciesName'
  belongs_to :prior_subspecies_name, class_name: 'SubspeciesName'

  def self.import data
    return unless data[:subspecies]

    if data[:species]
      species_name = data[:species].name_object
    else
      species_name = SpeciesName.import data
    end

    name = species_name.name.dup
    for subspecies in data[:subspecies]
      name << ' ' << subspecies[:type] if subspecies[:type]
      name << ' ' << subspecies[:species_group_epithet]
    end

    name_object = Name.find_by_name name
    return name_object if name_object

    subspecies = data[:subspecies].first
    name_object = create! name: name, epithet: subspecies[:species_group_epithet], subspecies_qualifier: subspecies[:type], species_name: species_name
    subspecies_name_object = name_object
    prior_name_object = name_object

    subspecies = data[:subspecies].second
    if subspecies
      name_object = create! name: name, epithet: subspecies[:species_group_epithet], subspecies_qualifier: subspecies[:type], species_name: species_name,
        prior_subspecies_name: prior_name_object
      prior_name_object.update_attribute :next_subspecies_name, name_object
    end

    subspecies_name_object
  end

  def rank
    'subspecies'
  end

end
