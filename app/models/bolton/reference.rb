class Bolton::Reference < ActiveRecord::Base
  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches
  set_table_name :bolton_references
  before_validation :set_year

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def principal_author_last_name
    authors.split(',').first
  end

  def match ward_reference
    return 0 unless ward_reference.principal_author_last_name == principal_author_last_name

    result = match_title ward_reference.title
    return result if result

    return 1 if reference_type == 'UnknownReference' || ward_reference.type == 'UnknownReference'

    1
  end

  private
  def match_title ward_title
    bolton_title = title.dup
    ward_title = ward_title.dup
    return 100 if bolton_title == ward_title
    return 90 if normalize(bolton_title) == normalize(ward_title)
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end 

  def normalize string
    remove_parenthesized_taxon_names string
    string.downcase!
    remove_bracketed_phrases string
    convert_accents_to_ascii string
    string.gsub! /[^\w\s]/, ''
    string
  end

  def convert_accents_to_ascii string
    string.replace string.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,"")
  end

  def remove_parenthesized_taxon_names string
    match = string.match(/ \(.+?\)/)
    return string unless match
    possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
    any_taxon_names = possible_taxon_names.any? do |word|
      ['Formicidae', 'Hymenoptera'].include? word
    end
    string[match.begin(0)..(match.end(0) - 1)] = '' if any_taxon_names
    string
  end

  def remove_bracketed_phrases string
    string.gsub!(/\s?\[.*?\]\s?/, ' ')
    string.strip!
    string
  end

end
