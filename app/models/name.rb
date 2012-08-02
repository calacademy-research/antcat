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
    Name.find_by_name(attributes[:name]) or create!(attributes)
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

  def to_html_with_fossil fossil
    string = ''.html_safe
    string << html_dagger if fossil
    string << html_name.html_safe
    string
  end
  alias :html_name_with_fossil :to_html_with_fossil

  def rank
    self.class.name[0, self.class.name.rindex('Name')].underscore
  end

  def self.make_epithet_set epithet
    EpithetSearchSet.new(epithet).epithets
  end

  def html_epithet_with_fossil fossil
    string = ''.html_safe
    string << html_dagger if fossil
    string << html_epithet.html_safe
    string
  end

  def html_dagger
    '&dagger;'.html_safe
  end

end
