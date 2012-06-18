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

  def self.add_epithets epithet, epithets, prefix, variant1, variant2
    if epithet =~ /[#{prefix}]#{variant1}$/
      epithets << epithet.gsub(/([#{prefix}])#{variant1}$/, "\\1#{variant2}")
      return true
    end
    if epithet =~ /[#{prefix}]#{variant2}$/
      epithets << epithet.gsub(/([#{prefix}])#{variant2}$/, "\\1#{variant1}")
      return true
    end
  end

  def self.replace_suffix epithet, prefix, suffix, new_suffix
    epithet.gsub /([#{prefix}])#{suffix}$/, "\\1#{new_suffix}"
  end

  def self.has_suffix epithet, prefix, suffix
    epithet =~ /[#{prefix}]#{suffix}$/
  end

  def self.add_ii_epithets epithet, epithets
    consonants = 'bcdfghjklmnprstvxyz'
    if has_suffix epithet, consonants, 'ii'
      epithets << replace_suffix(epithet, consonants, 'ii', 'i')
      epithets << replace_suffix(epithet, consonants, 'ii', 'iae')
      return true
    end
    if has_suffix epithet, consonants, 'iae'
      epithets << replace_suffix(epithet, consonants, 'iae', 'ii')
      return true
    end
    if has_suffix epithet, consonants, 'i'
      epithets << replace_suffix(epithet, consonants, 'i', 'ii')
      epithets << replace_suffix(epithet, consonants, 'i', 'ae')
      return true
    end
    if has_suffix epithet, consonants, 'ae'
      epithets << replace_suffix(epithet, consonants, 'ae', 'i')
      return true
    end
  end

  def self.make_epithet_set epithet
    consonants = 'bcdfghjklmnprstvxyz'
    epithets = [epithet]
    add_ii_epithets(epithet, epithets) or
    add_epithets(epithet, epithets, consonants, 'a',  'us') or
    add_epithets(epithet, epithets, consonants + 'q', 'ua', 'uus') or
    add_epithets(epithet, epithets, consonants, 'ea', 'eus')
    epithets
  end
end
