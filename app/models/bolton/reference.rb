# coding: UTF-8
class Bolton::Reference < ActiveRecord::Base
  include ReferenceComparable
  set_table_name :bolton_references

  belongs_to :match, :class_name => '::Reference'
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :possible_matches, :through => :matches, :source => :reference

  before_validation :set_year

  searchable do
    text :original
    integer :id
  end

  def self.do_search options = {}
    query =
      select('DISTINCT bolton_references.*').
        joins('LEFT OUTER JOIN bolton_matches ON bolton_matches.bolton_reference_id = bolton_references.id').
        paginate(:page => options[:page])

    if options[:match_threshold].present?
      query = query.where 'similarity <= ?', options[:match_threshold]
    end

    if options[:match_statuses].present?
      query_clauses = []
      query_clauses << 'match_status IS NULL' if options[:match_statuses].include? nil
      query_clauses << 'match_status = "auto"' if options[:match_statuses].include? 'auto'
      query_clauses << 'match_status = "manual"' if options[:match_statuses].include? 'manual'
      query_clauses << 'match_status = "unmatcheable"' if options[:match_statuses].include? 'unmatcheable'
      query = query.where query_clauses.join(' OR ') unless query_clauses.empty?
    end

    if options[:q].present?
      solr_result_ids = search {
        keywords options[:q]
        order_by :id
        paginate :per_page => 5_000
      }.results.map &:id
      query = query.where('bolton_references.id' => solr_result_ids).paginate(:page => options[:page])
    end

    query
  end

  def set_match
    if matches.size == 1 && matches.first.similarity >= 0.8
      self.match = matches.first.reference
      self.match_status = 'auto'
    else
      self.match = nil
      self.match_status = nil
    end
    save!
  end

  def set_match_manually string
    if string == 'unmatcheable'
      self.match = nil
      self.match_status = 'unmatcheable'
    elsif string
      self.match = ::Reference.find string.to_i
      self.match_status = 'manual'
    else
      self.match = nil
      self.match_status = nil
    end
    save!
  end

  def self.set_matches
    all.each {|e| e.set_match}
  end

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def best_match_similarity
    matches.first && matches.first.similarity
  end

  def possible_matches_with_matched_first
    possible_matches.partition {|m| m == match}.flatten
  end

  def self.match_status_auto_count
    where(:match_status => 'auto').count
  end

  def self.match_status_manual_count
    where(:match_status => 'manual').count
  end

  def self.match_status_none_count
    where(:match_status => nil).count
  end

  def self.match_status_unmatcheable_count
    where(:match_status => 'unmatcheable').count
  end

  # ReferenceComparable
  def author; authors.split(',').first; end
  def type; reference_type; end

  private
  def set_year
    self.year = ::Reference.get_year citation_year
  end

end
