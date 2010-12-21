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
    return 1 if reference_type == 'UnknownReference' || ward_reference.type == 'UnknownReference'
    return 100 if title == ward_reference.title
    return 90 if remove_parenthesized_taxon_names(title) == remove_parenthesized_taxon_names(ward_reference.title)
    return 90 if remove_bracketed_phrases(title) == remove_bracketed_phrases(ward_reference.title)
    1
  end

  private
  def set_year
    self.year = ::Reference.get_year citation_year
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
    string.gsub(/\s?\[.*?\]\s?/, ' ').strip
  end

end
