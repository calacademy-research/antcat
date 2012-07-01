class Name < ActiveRecord::Base

  validates :name, presence: true

  def self.import data
    SubspeciesName.import_data(data) or
    SpeciesName.import_data(data)    or
    SubgenusName.import_data(data)   or
    GenusName.import_data(data)      or
    SubtribeName.import_data(data)   or
    TribeName.import_data(data)      or
    SubfamilyName.import_data(data)  or
    FamilyName.import_data(data)     or
    FamilyOrSubfamilyName.import_data(data) or
    raise "No Name subclass wanted #{data}"
  end

  def self.import_data data
    return unless name = get_name(data)
    attributes = make_attributes name, data
    existing_name = Name.find_by_name attributes[:name]
    return existing_name if existing_name
    create! attributes
  end

  def self.make_attributes name, data
    {name: name, html_name: name, epithet: name, html_epithet: name}
  end

  def to_s
    name
  end

  def to_html
    html_name
  end

  def rank
    self.class.name[0, self.class.name.rindex('Name')].underscore
  end

  def self.make_epithet_set epithet
    EpithetSearchSet.new(epithet).epithets
  end

end
