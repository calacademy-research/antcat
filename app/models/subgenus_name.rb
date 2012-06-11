class SubgenusName < GenusGroupName

  belongs_to :genus_group_name
  validates :genus_group_name, presence: true

  def self.import data
    return unless epithet = data[:subgenus_epithet]
    if data[:genus]
      genus_group_name = data[:genus].name_object
    else
      genus_group_name = GenusName.import genus_name: data[:genus_name]
    end

    name_object = Name.find_by_genus_group_name_id_and_epithet genus_group_name.id, epithet
    return name_object if name_object

    name = genus_group_name.name + ' (' + epithet + ')'
    create! name: name, epithet: epithet, genus_group_name: genus_group_name
  end

  def rank
    'subgenus'
  end

end
