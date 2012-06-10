class SpeciesName < Name

  belongs_to :genus_group_name
  validates :genus_group_name, presence: true

  def self.import data
    return unless data[:species_epithet]

    genus_group_name = data[:genus].try :name_object
    genus_group_name = GenusName.import(genus_name: data[:genus_name]) unless genus_group_name
      #genus_group_name = GenusName.find_by_name data[:genus_name]
    #if genus_group_name
      #name_object = self.class.find_by_genus_group_name_id genus_group_name.id, data[:species_epithet]
      #return name_object if name_object

    create! genus_group_name: genus_group_name,
            epithet:          data[:species_epithet],
            name:             data[:species_epithet]
  end

  def full_name
    genus_group_name.name + ' ' + epithet
  end

end
