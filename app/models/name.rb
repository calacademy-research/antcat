# coding: UTF-8
class Name < ActiveRecord::Base
  include Formatters::Formatter
  include UndoTracker

  validates :name, presence: true
  after_save :set_taxon_caches
  has_paper_trail meta: {change_id: :get_current_change_id}

  attr_accessible :name,
                  :name_html,
                  :epithet,
                  :epithet_html,
                  :epithets,
                  :type,
                  :epithet,
                  :epithet_html,
                  :gender,
                  :nonconforming_name

  scope :find_all_by_name, lambda { |name| where name: name }


  def change name_string
    existing_names = Name.where('id != ?', id).find_all_by_name(name_string)
    raise Taxon::TaxonExists if existing_names.any? { |name| not name.references.empty? }
    update_attributes!({
                           name: name_string,
                           name_html: italicize(name_string),
                       })
  end

  def change_parent _;
  end

  def quadrinomial?
    name.split(' ').size == 4
  end

  def at index
    name.split(' ')[index]
  end

  def set_taxon_caches


    #Taxon.update_all ['name_cache = ?', name], name_id: id
    Taxon.where(name_id: id).update_all(name_cache: name)
    #Taxon.update_all ['name_html_cache = ?', name_html], name_id: id
    #Taxon.update_all({name_html_cache: name_html}, {name_id: id})
    Taxon.where(name_id: id).update_all(name_html_cache: name_html)
  end

  def words
    @_words ||= name.split ' '
  end

  # Irregular flag allows parsing of names that don't conform to naming standards so we can support bad spellings.
  def self.parse string, irregular=false
    return parse_replacement string, irregular # redirect call to replacement method
    raise "we should never get here..."
    # explicit loading seems to help Citrus's problem with reloading its grammars
    # when Rails's class caching is off
    Citrus.load Rails.root.to_s + '/lib/parsers/common_grammar', force: true unless defined? Parsers::CommonGrammar
    Citrus.load Rails.root.to_s + '/lib/parsers/author_grammar', force: true unless defined? Parsers::AuthorGrammar
    Citrus.load Rails.root.to_s + '/lib/importers/bolton/catalog/grammar', force: true unless defined? Importers::Bolton::Catalog::Grammar

    word_count = string.split(' ').count


    name_class = Name.parse_rank string

    if name_class.nil? and irregular

      name_class = SpeciesName
    else
      raise "No Name subclass wanted the string: #{string}" unless name_class
    end
    words = string.split ' '

    output = name_class.parse_words(words)
    output_replacement = parse_replacement string

    output_string = make_output_comparable output
    output_replacement_string = make_output_comparable output_replacement

    unless output_string == output_replacement_string
      File.open('self.parse', 'a') do |file|
        file.puts "#{string} (#{irregular})"
        file.puts "output: #{output.inspect}"
        file.puts "replac: #{output_replacement.inspect}\n"
      end
    end

    output
  end

  # refactor helper
  def self.make_output_comparable output
    output.inspect.to_s
      .gsub(/ id: \d+,/, '')
      .gsub(/ created_at: .*?,/, '')
      .gsub(/ updated_at: .*?,/, '')
  end

  def self.i_tagify string
    "<i>#{string}</i>"
  end

  # to replace #self.parse
  def self.parse_replacement string, irregular
    words = string.split " "

    name_type = case words.size
                when 1 then :genus_or_tribe_subfamily
                when 2 then :species
                when 3 then :subspecies
                when 4..5 then :subspecies_with_two_epithets
                end

    if name_type == :genus_or_tribe_subfamily
      name_type = case string
                  when /inae$/ then :subfamily
                  when /idae$/ then :subfamily # actually a family name, but let's rewrite the old
                                               # method before changing the behavior; edge case anyway
                  when /ini$/ then :tribe
                  else :genus end
    end

    case name_type
    when :subspecies
      return SubspeciesName.create!(
        name: string,
        name_html: i_tagify(string),
        epithet: words.third,
        epithet_html: i_tagify(words.third),
        epithets: [words.second, words.third].join(' ')
      )

    when :subspecies_with_two_epithets
      return SubspeciesName.create!(
        name: string,
        name_html: i_tagify(string),
        epithet: words.last,
        epithet_html: i_tagify(words.last),
        epithets: words[1..-1].join(' ')
      )

    when :species
      return SpeciesName.create!(
        name: string,
        name_html: i_tagify(string),
        epithet: words.second,
        epithet_html: i_tagify(words.second)
      )

    when :genus
        return GenusName.create!(
          name: string,
          name_html: i_tagify(string),
          epithet: string,
          epithet_html: i_tagify(string)
          #protonym_html: i_tagify(string)
          # Note: GenusName.find_each {|t| puts "#{t.name_html == t.protonym_html} #{t.name_html} #{t.protonym_html}" }
          # => all true except Aretidris because protonym_html is nil
        )
    when :tribe
        return TribeName.create!(
          name: string,
          name_html: string,
          epithet: string,
          epithet_html: string
          #protonym_html: string
        )
    when :subfamily
        return SubfamilyName.create!(
          name: string,
          name_html: string,
          epithet: string,
          epithet_html: string
          #protonym_html: string
          # Note: SubfamilyName.all.map {|t| t.name == t.protonym_html }.uniq # => true
        )
    end

    if irregular
      return SpeciesName.create!(
        name: string,
        name_html: i_tagify(string),
        epithet: words.second,
        epithet_html: i_tagify(words.second)
      )
    end
    raise "No Name subclass wanted the string: #{string}" # from the original method
  end

  def self.parse_words words
    return unless words.size == 1
    create! make_import_attributes words[0]
  end

  #
  # Removes subgenus before evaluating
  #
  def self.parse_rank string
    # extremely kludgey
    word_count = string.split(' ').count
    # # Subgenus matcher
    # if word_count == 3
    #   if  match = string.match(/^([a-zA-Z]+) (\(([a-zA-Z]+)\)) ([a-zA-Z]+)/)
    #     string = match[1] + " " + match[4]
    #     word_count = 2
    #     puts ("subgenus stripped - now it's #{string}")
    #   end
    # end
    return SubspeciesName if word_count >= 3
    for key in [:subfamily_name, :tribe_name, :genus_name, :species_name]
      begin
        result = Importers::Bolton::Catalog::Grammar.parse(string, root: key).value
        if key == :species_name && result.has_key?(:genus_name) && result.has_key?(:species_epithet)
          return SpeciesName
        end
      rescue Citrus::ParseError => e
        next
      end
      return key.to_s.camelize.constantize if result.has_key? key
    end
    nil
  end

  def self.picklist_matching letters_in_name, options = {}
    join = options[:taxa_only] ||
        options[:species_only] ||
        options[:genera_only] ||
        options[:subfamilies_or_tribes_only] ? 'JOIN' : 'LEFT OUTER JOIN'
    rank_filter =
        case
          when options[:species_only] then
            'AND taxa.type = "Species"'
          when options[:genera_only] then
            'AND taxa.type = "Genus"'
          when options[:subfamilies_or_tribes_only] then
            'AND (taxa.type = "Subfamily" OR taxa.type = "Tribe")'
          else
            ''
        end

    # I do not see why the code beginning with Name.select can't be factored out, but it can't
    search_term = letters_in_name + '%'
    prefix_matches =
        Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').
            joins("#{join} taxa ON taxa.name_id = names.id").
            where("name LIKE '#{search_term}' #{rank_filter}").
            order('taxon_id desc').
            order(:name)

    search_term = letters_in_name.split('').join('%') + '%'
    epithet_matches =
        Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').
            joins("#{join} taxa ON taxa.name_id = names.id").
            where("epithet LIKE '#{search_term}' #{rank_filter}").
            order(:epithet)

    search_term = letters_in_name.split('').join('%') + '%'
    first_then_any_letter_matches =
        Name.select('names.id AS id, name, name_html, taxa.id AS taxon_id').
            joins("#{join} taxa ON taxa.name_id = names.id").
            where("name LIKE '#{search_term}' #{rank_filter}").
            order(:name)

    [picklist_matching_format(prefix_matches),
     picklist_matching_format(epithet_matches),
     picklist_matching_format(first_then_any_letter_matches),
    ].flatten.uniq { |item| item[:name] }[0, 100]
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
        SpeciesName.import_data(data) or
        SubgenusName.import_data(data) or
        GenusName.import_data(data) or
        CollectiveGroupName.import_data(data) or
        SubtribeName.import_data(data) or
        TribeName.import_data(data) or
        SubfamilyName.import_data(data) or
        FamilyName.import_data(data) or
        FamilyOrSubfamilyName.import_data(data) or
        OrderName.import_data(data) or
        raise "No Name subclass wanted to import #{data}"
  end

  def self.import_data data
    return unless name = get_name(data)
    attributes = make_import_attributes name, data
    Name.find_by_name(attributes[:name]) or create!(attributes)
  end

  def self.make_import_attributes name, data = nil
    {name: name, name_html: name, epithet: name, epithet_html: name}
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

    string << name_html.html_safe

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
      table = klass.arel_table
      for field in fields
        for record in klass.where(table[field].matches("%{nam #{id}}%"))
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

  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false).
        where(name: string).order('taxa.id desc').order(:name).first
  end

end
