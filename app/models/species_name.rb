class SpeciesName < Name

  belongs_to :genus_group_name
  validates :genus_group_name, presence: true

  def self.import data
    return unless data[:species_epithet]

    if data[:genus]
      genus_group_name = data[:genus].name_object
    else
      genus_group_name = GenusName.import genus_name: data[:genus_name]
    end

    name = Name.find_by_genus_group_name_id_and_epithet genus_group_name.id, data[:species_epithet]
    return name if name

    create! name: data[:species_epithet], epithet: data[:species_epithet], genus_group_name: genus_group_name
  end

  def full_name
    genus_group_name.name + ' ' + epithet
  end

end
