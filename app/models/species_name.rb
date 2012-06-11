class SpeciesName < Name

  belongs_to :genus_group_name
  validates :genus_group_name, presence: true

  def self.import data
    return unless data[:species_epithet]

    if data[:subgenus_epithet]
      genus_group_name = SubgenusName.import data
    elsif data[:genus]
      genus_group_name = data[:genus].name_object
    else
      genus_group_name = GenusName.import data
    end

    name = Name.find_by_genus_group_name_id_and_epithet genus_group_name.id, data[:species_epithet]
    return name if name

    create!({
      name:             genus_group_name.name + ' ' + data[:species_epithet],
      epithet:          data[:species_epithet],
      genus_group_name: genus_group_name,
    })
  end

  def rank
    'species'
  end

end
