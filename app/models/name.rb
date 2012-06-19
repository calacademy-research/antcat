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
    epithets = [epithet]
    epithets.concat first_declension_nominative_singular(epithet)
    epithets.concat first_declension_genitive_singular(epithet)
    epithets.concat make_deemed_identical_set(epithet)
    epithets.uniq
  end

  def self.decline epithet, stem, endings
    epithets = []
    endings_regexp = '(' + endings.join('|') + ')'
    return epithets unless epithet =~ /#{stem}#{endings_regexp}$/
    for ending in endings
      epithets << epithet.gsub(/(#{stem})#{endings_regexp}$/, "\\1#{ending}")
    end
    epithets
  end

  def self.first_declension_nominative_singular epithet
    decline epithet, '(?:[bcdfghjklmnprstvxyz][ei]?|qu)', ['us', 'a', 'um']
  end

  def self.first_declension_genitive_singular epithet
    decline epithet, '[bcdfghjklmnprstvxyz]i?', ['i', 'ae']
  end

  def self.make_deemed_identical_set epithet
    epithets = []
    if has_ending epithet, 'i'
      epithets << replace_ending(epithet, 'i', 'ii')
    elsif has_ending epithet, 'ii'
      epithets << replace_ending(epithet, 'ii', 'i')
    end
    epithets
  end

  def self.has_ending epithet, ending, stem = '[bcdfghjklmnprstvxyz]'
    epithet =~ /#{stem}#{ending}$/
  end

  def self.replace_ending epithet, old_ending, new_ending, stem = '[bcdfghjklmnprstvxyz]'
    epithet.gsub /(#{stem})#{old_ending}$/, "\\1#{new_ending}"
  end

end
