class Name < ActiveRecord::Base

  validates :name, presence: true

  after_save :set_taxon_caches

  def set_taxon_caches
    Taxon.update_all ['name_cache = ?', name], name_id: id
    Taxon.update_all ['name_html_cache = ?', name_html], name_id: id
  end

  def self.parse string
    words = string.split ' '
    GenusName.parse_words(words)  or
    SpeciesName.parse_words(words) or
    SubspeciesName.parse_words(words) or
    raise "No Name subclass wanted the string: #{string}"
  end

  def self.picklist_matching letters_in_name
    # I do not see why the code beginning with Name.select can't be factored out, but it can't
    search_term = letters_in_name + '%'
    prefix_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins('LEFT OUTER JOIN taxa ON taxa.name_id = names.id').where("name LIKE '#{search_term}'").order(:name)

    search_term = letters_in_name.split('').join('%') + '%'
    epithet_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins('LEFT OUTER JOIN taxa ON taxa.name_id = names.id').where("epithet LIKE '#{search_term}'").order(:epithet)

    search_term = letters_in_name.split('').join('%') + '%'
    first_then_any_letter_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins('LEFT OUTER JOIN taxa ON taxa.name_id = names.id').where("name LIKE '#{search_term}'").order(:name)

    [picklist_matching_format(prefix_matches),
     picklist_matching_format(epithet_matches),
     picklist_matching_format(first_then_any_letter_matches),
    ].flatten.uniq {|item| item[:name]}
  end

  def self.picklist_matching_format matches
    matches.map do |e|
      result = {id: e.id.to_i, name: e.name, label: "<b>#{e.name_html}</b>", value: e.name}
      result[:taxon_id] = e.taxon_id.to_i if e.taxon_id
      result
    end
  end

  def self.import data
    SubspeciesName.import_data(data) or
    SpeciesName.import_data(data)    or
    SubgenusName.import_data(data)   or
    GenusName.import_data(data)      or
    CollectiveGroupName.import_data(data) or
    SubtribeName.import_data(data)   or
    TribeName.import_data(data)      or
    SubfamilyName.import_data(data)  or
    FamilyName.import_data(data)     or
    FamilyOrSubfamilyName.import_data(data) or
    OrderName.import_data(data)      or
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
