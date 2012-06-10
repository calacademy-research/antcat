class SpeciesName < Name

  belongs_to :genus_name
  validates :genus_name, presence: true

  def self.import data
    return unless data[:species_epithet]
    #genus_name_object = GenusName.find_by_name data[:genus_name_object]
    #if genus_name_object
      #name_object = self.class.find_by_genus_name_id_and_name genus_name_object.id, data[:species_epithet]
      #return name_object if name_object
    #else
      #genus_name_object = GenusName.import(data)
    #end

    create! genus_name: Name.import(genus_name: data[:genus_name]),
            epithet:    data[:species_epithet],
            name:       data[:species_epithet]
  end

  def full_name
    genus_name.name + ' ' + epithet
  end

end
