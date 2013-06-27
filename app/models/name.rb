# coding: UTF-8
class Name < ActiveRecord::Base
  validates :name, presence: true
  after_save :set_taxon_caches
  has_paper_trail

  def change name_string
    existing_names = Name.where('id != ?', id).find_all_by_name(name_string)
    raise Taxon::TaxonExists if existing_names.any? {|name| not name.references.empty?}
    update_attributes!({
      name:           name_string,
      name_html:      Formatters::Formatter.italicize(name_string),
    })
  end

  def quadrinomial?
    name.split(' ').size == 4
  end

  def at index
    name.split(' ')[index]
  end

  def set_taxon_caches
    Taxon.update_all ['name_cache = ?', name], name_id: id
    Taxon.update_all ['name_html_cache = ?', name_html], name_id: id
  end

  def words
    @_words ||= name.split ' '
  end

  def self.parse string
    words = string.split ' '
    GenusName.parse_words(words)  or
    SpeciesName.parse_words(words) or
    SubspeciesName.parse_words(words) or
    raise "No Name subclass wanted the string: #{string}"
  end

  def self.picklist_matching letters_in_name, options = {}
    join = options[:taxa_only] || options[:species_only] || options[:genera_only] ? 'JOIN' : 'LEFT OUTER JOIN'
    rank_filter =
      case
      when options[:species_only] then 'AND taxa.type = "Species"'
      when options[:genera_only] then 'AND taxa.type = "Genus"'
      else ''
      end

    # I do not see why the code beginning with Name.select can't be factored out, but it can't
    search_term = letters_in_name + '%'
    prefix_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins("#{join} taxa ON taxa.name_id = names.id").where("name LIKE '#{search_term}' #{rank_filter}").order(:name)

    search_term = letters_in_name.split('').join('%') + '%'
    epithet_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins("#{join} taxa ON taxa.name_id = names.id").where("epithet LIKE '#{search_term}' #{rank_filter}").order(:epithet)

    search_term = letters_in_name.split('').join('%') + '%'
    first_then_any_letter_matches =
      Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').joins("#{join} taxa ON taxa.name_id = names.id").where("name LIKE '#{search_term}' #{rank_filter}").order(:name)

    [picklist_matching_format(prefix_matches),
     picklist_matching_format(epithet_matches),
     picklist_matching_format(first_then_any_letter_matches),
    ].flatten.uniq {|item| item[:name]}[0, 100]
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

  def self.duplicates
    name_strings = Name.find_by_sql("SELECT * FROM names GROUP by name HAVING COUNT(*) > 1").map(&:name)
    Name.where(name: name_strings).order(:name)
  end

  def self.duplicates_with_references options = {}
    results = {}
    dupes = duplicates
    Progress.new_init show_progress: options[:show_progress], total_count: dupes.size, show_errors: true
    dupes.each do |duplicate|
      Progress.puts duplicate.name
      Progress.tally_and_show_progress 1
      results[duplicate.name] ||= {}
      results[duplicate.name][duplicate.id] = duplicate.references
    end
    Progress.show_results
    results
  end

  def references
    references = []
    references.concat references_in_fields
    references.concat references_in_taxt
    references
  end

  def references_in_fields
    references = []
    references.concat references_to_taxon_name
    references.concat references_to_taxon_type_name
    references.concat references_to_protonym_name
    references
  end

  def references_to_taxon_name
    Taxon.where(name_id: id).inject([]) do |references, taxon|
      references << {table: 'taxa', field: :name_id, id: taxon.id}
      references
    end
  end

  def references_to_taxon_type_name
    Taxon.where(type_name_id: id).inject([]) do |references, taxon|
      references << {table: 'taxa', field: :type_name_id, id: taxon.id}
      references
    end
  end

  def references_to_protonym_name
    Protonym.where(name_id: id).inject([]) do |references, protonym|
      references << {table: 'protonyms', field: :name_id, id: protonym.id}
      references
    end
  end

  def references_in_taxt
    references = []
    Taxt.taxt_fields.each do |klass, fields|
      for record in klass.send :all
        for field in fields
          next unless record[field]
          if record[field] =~ /{nam #{id}}/
            references << {table: klass.table_name, field: field, id: record[:id]}
          end
        end
      end
    end
    references
  end

  def self.destroy_duplicates options = {}
    duplicates_with_references(options).each do |name, duplicate|
      duplicate.each do |id, references|
        Name.find(id).destroy unless references.present?
      end
    end
  end

  def self.find_trinomials_like_quadrinomials
    Name.all.inject([]) do |names, name|
      if name.quadrinomial?
        if trinomial = Name.find_by_name("#{name.at(0)} #{name.at(1)} #{name.at(3)}")
          if taxon = Taxon.find_by_name(trinomial.name)
            unless taxon.unavailable?
              names << trinomial.name
            end
          end
        end
      end
      names
    end
  end

end
