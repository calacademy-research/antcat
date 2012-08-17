class Name < ActiveRecord::Base

  validates :name, presence: true, uniqueness: true

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
    attributes = make_import_attributes name, data
    Name.find_by_name(attributes[:name]) or create!(attributes)
  end

  def self.make_import_attributes name, data
    {name: name, name_html: name, epithet: name, epithet_html: name, protonym_html: name}
  end

  def to_s
    name
  end

  def to_html
    name_html
  end

  def to_html_with_fossil fossil
    string = ''.html_safe
    string << dagger_html if fossil
    string << name_html.html_safe
    string
  end

  def rank
    self.class.name[0, self.class.name.rindex('Name')].underscore
  end

  def self.make_epithet_set epithet
    EpithetSearchSet.new(epithet).epithets
  end

  def epithet_with_fossil_html fossil
    string = ''.html_safe
    string << dagger_html if fossil
    string << epithet_html.html_safe
    string
  end

  def protonym_with_fossil_html fossil
    string = ''.html_safe
    string << dagger_html if fossil
    if protonym_html.present?
      string << protonym_html.html_safe
    else
      string << name_html.html_safe
    end
    string
  end

  def dagger_html
    '&dagger;'.html_safe
  end

end
