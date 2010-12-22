class Bolton::Reference < ActiveRecord::Base
  set_table_name :bolton_references

  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches

  before_validation :set_year

  def match ward_reference
    return 0 unless ward_reference.principal_author_last_name == principal_author_last_name

    result = nil
    return result if result = match_title(ward_reference.title)
    return result if result = match_article(ward_reference)

    1
  end

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def principal_author_last_name
    authors.split(',').first
  end

  private
  def match_title ward_title
    return 100 if ward_title == title
    return 90 if normalize_title(title) == normalize_title(ward_title)
  end

  def match_article ward_reference
    return unless ward_reference.type == 'ArticleReference' && reference_type == 'ArticleReference' &&
                  ward_reference.series_volume_issue.present? && series_volume_issue.present? &&
                  ward_reference.pagination.present? && pagination.present?
    return unless ward_reference.pagination == pagination
    return 85 if normalize_series_volume_issue(ward_reference.series_volume_issue) == normalize_series_volume_issue(series_volume_issue)
    80
  end

  def normalize_series_volume_issue string
    string.gsub /\s\(/, '('
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end 

  def normalize_title string
    string = string.dup
    remove_parenthesized_taxon_names! string
    string.downcase!
    remove_bracketed_phrases! string
    convert_accents_to_ascii! string
    string.gsub! /[^\w\s]/, ''
    string
  end

  def convert_accents_to_ascii! string
    string.replace string.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,"")
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
