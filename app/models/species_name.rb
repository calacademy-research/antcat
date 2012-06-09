class SpeciesName < Name

  belongs_to :genus_name
  validates :genus_name, presence: true

  def import _, data
    genus_name = GenusName.find_or_create_by_name data[:genus_name]
    name_object = self.class.find_by_genus_name_id_and_name genus_name.id, name
    return name_object if name_object

    self.genus_name = GenusName.find_or_create_by_name data[:genus_name]
    self.epithet = data[:species_epithet]
    self.name = genus_name.name + ' ' + epithet
    save!

    self
  end

end
