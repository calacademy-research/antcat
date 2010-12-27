class Bolton::Reference < ActiveRecord::Base
  set_table_name :bolton_references

  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches

  before_validation :set_year

  named_scope :with_confidence, lambda {|confidence| {
    :joins => :matches,
    :conditions => ['confidence = ?', confidence]
  }}

  def match ward_reference
    return 0 unless convert_accents_to_ascii(ward_reference.principal_author_last_name) ==
                    convert_accents_to_ascii(principal_author_last_name)

    result = match_title(ward_reference) || match_article(ward_reference) || match_book(ward_reference)
    year_matches = year_matches? ward_reference

    case
    when !result && !year_matches then 0
    when !result && year_matches then 10
    when result && !year_matches then result - 50
    else result
    end
  end

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def match_year year
    self.year.to_i == year
  end

  def principal_author_last_name
    authors.split(',').first
  end

  private
  def year_matches? ward_reference
    return unless ward_reference.year && year
    (ward_reference.year - year.to_i).abs <= 1
  end

  def match_title ward_reference
    ward_title = ward_reference.title.dup
    bolton_title = title.dup
    return 100 if normalize_title!(ward_title) == normalize_title!(bolton_title)
    return 95 if remove_bracketed_phrases!(ward_title) == remove_bracketed_phrases!(bolton_title)
    return 100 if remove_punctuation!(ward_title) == remove_punctuation!(bolton_title)
  end

  def match_article ward_reference
    return unless ward_reference.type == 'ArticleReference' && reference_type == 'ArticleReference' &&
      ward_reference.series_volume_issue.present? && series_volume_issue.present? &&
      ward_reference.pagination.present? && pagination.present? &&
      ward_reference.pagination == pagination

    return 90 if normalize_series_volume_issue(ward_reference.series_volume_issue) ==
                 normalize_series_volume_issue(series_volume_issue)
  end

  def match_book ward_reference
    return unless ward_reference.type == 'BookReference' && reference_type == 'BookReference' &&
      ward_reference.pagination.present? && pagination.present?
    return 80 if ward_reference.pagination == pagination
  end

  def normalize_series_volume_issue string
    string = string.dup
    remove_space_before_or_after_parenthesis! string
    remove_year_in_parentheses! string
    remove_No! string
    string
  end

  def remove_space_before_or_after_parenthesis! string
    string.gsub! /\s?([\(\)])\s?/, '\1'
    string
  end

  def remove_year_in_parentheses! string
    string.gsub! /\(\d{4}\)$/, ''
    string
  end

  def remove_No! string
    string.gsub! /\(No. (\d+)\)$/, '(\1)'
    string
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end 

  def normalize_title! string
    remove_parenthesized_taxon_names! string
    string.downcase!
    convert_accents_to_ascii! string
    string
  end

  def remove_punctuation! string
    string.gsub! /[^\w\s]/, ''
    string
  end

  def convert_accents_to_ascii! string
    string.replace convert_accents_to_ascii string
  end

  def convert_accents_to_ascii string
    string.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,"")
  end

  def remove_parenthesized_taxon_names! string
    match = string.match(/ \(.+?\)/)
    return string unless match
    possible_taxon_names = match.to_s.strip.gsub(/[(),:]/, '').split(/[ ]/)
    any_taxon_names = possible_taxon_names.any? do |word|
      ['Formicidae', 'Hymenoptera'].include? word
    end
    string[match.begin(0)..(match.end(0) - 1)] = '' if any_taxon_names
    string
  end

  def remove_bracketed_phrases! string
    string.gsub!(/\s?\[.*?\]\s?/, ' ')
    string.strip!
    string
  end

end
