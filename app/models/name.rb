# All `Name` subclasses are for taxa. `AuthorName`s are used for references.
# TODO add `self.abstract_class = true`? Many specs will break.

class Name < ApplicationRecord
  include UndoTracker
  include Formatters::RefactorFormatter

  attr_accessible :epithet, :epithet, :epithet_html, :epithet_html, :epithets,
    :gender, :name, :name_html, :nonconforming_name, :type

  validates :name, presence: true

  after_save :set_taxon_caches

  has_paper_trail meta: { change_id: :get_current_change_id }

  def change name_string
    existing_names = Name.where.not(id: id).where(name: name_string)
    raise Taxon::TaxonExists if existing_names.any? { |name| not name.references.empty? }
    update_attributes! name: name_string, name_html: italicize(name_string)
  end

  def change_parent _; end

  def quadrinomial?
    name.split(' ').size == 4
  end

  # Feel free to refactor this. It was written to replace code that 1) made some initial
  # parsing using Citrus 2) dynamically called `name_class.parse_words(words)` depending on
  # what Citrus returned 3) which initiated [depending on subclass] a long call chain involving
  # importer methods that we really had to remove.
  # Added in ac9a8a; refer to the change log for more commit ids.
  #
  # Irregular flag allows parsing of names that don't conform to naming standards so we can support bad spellings.
  def self.parse string, irregular = false
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
        epithet: words.second, #is this used?
        epithet_html: i_tagify(words.second) #is this used?
      )

    when :genus
      return GenusName.create!(
        name: string,
        name_html: i_tagify(string),
        epithet: string, #is this used?
        epithet_html: i_tagify(string) #is this used?
        #protonym_html: i_tagify(string) #is this used?
        # Note: GenusName.find_each {|t| puts "#{t.name_html == t.protonym_html} #{t.name_html} #{t.protonym_html}" }
        # => all true except Aretidris because protonym_html is nil
      )
    when :tribe
      return TribeName.create!(
        name: string,
        name_html: string,
        epithet: string, #is this used?
        epithet_html: string #is this used?
        #protonym_html: string
      )
    when :subfamily
      return SubfamilyName.create!(
        name: string,
        name_html: string,
        epithet: string, #is this used?
        epithet_html: string #is this used?
        #protonym_html: string #is this used?
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

  def self.i_tagify string
    "<i>#{string}</i>"
  end

  def self.picklist_matching letters_in_name, options = {}
    Names::PicklistMatching.new(letters_in_name, options).call
  end

  def to_s
    name
  end

  def to_html
    name_html
  end

  def to_html_with_fossil fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def rank
    self.class.name.gsub(/Name$/, "").underscore
  end

  def self.make_epithet_set epithet
    EpithetSearchSet.new(epithet).epithets
  end

  def epithet_with_fossil_html fossil
    "#{dagger_html if fossil}#{epithet_html}".html_safe
  end

  def protonym_with_fossil_html fossil
    "#{dagger_html if fossil}#{name_html}".html_safe
  end

  def dagger_html
    '&dagger;'.html_safe
  end

  def self.duplicates
    name_strings = Name.find_by_sql(<<-SQL).map(&:name)
      SELECT * FROM names GROUP BY name HAVING COUNT(*) > 1
    SQL
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
    references_in_fields.concat(references_in_taxt)
  end

  def self.find_by_name string
    Name.joins("LEFT JOIN taxa ON (taxa.name_id = names.id)").readonly(false)
      .where(name: string).order('taxa.id DESC').order(:name).first
  end

  private
    def words
      @_words ||= name.split ' '
    end

    def set_taxon_caches
      Taxon.where(name: self).update_all(name_cache: name)
      Taxon.where(name: self).update_all(name_html_cache: name_html)
    end

    def references_in_fields
      references_to_taxon_name
        .concat(references_to_taxon_type_name)
        .concat(references_to_protonym_name)
    end

    def references_to_taxon_name
      Taxon.where(name: self).map do |taxon|
        { table: 'taxa', field: :name_id, id: taxon.id }
      end
    end

    def references_to_taxon_type_name
      Taxon.where(type_name: self).map do |taxon|
        { table: 'taxa', field: :type_name_id, id: taxon.id }
      end
    end

    def references_to_protonym_name
      Protonym.where(name: self).map do |protonym|
        { table: 'protonyms', field: :name_id, id: protonym.id }
      end
    end

    def references_in_taxt
      references = []
      Taxt::TAXT_FIELDS.each do |klass, fields|
        table = klass.arel_table
        fields.each do |field|
          klass.where(table[field].matches("%{nam #{id}}%")).each do |record|
            next unless record[field]
            if record[field] =~ /{nam #{id}}/
              references << { table: klass.table_name, field: field, id: record[:id] }
            end
          end
        end
      end
      references
    end
end
