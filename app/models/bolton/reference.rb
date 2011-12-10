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

    if options[:match_types].present?
      query_clauses = []
      query_clauses << 'match_type IS NULL' if options[:match_types].include? nil
      query_clauses << 'match_type = "auto"' if options[:match_types].include? 'auto'
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
      self.match_type = 'auto'
    else
      self.match = nil
      self.match_type = nil
    end
    save!
  end

  def set_match_manually reference
    self.match = reference
    self.match_type = 'manual'
    save!
  end

  def self.set_matches
    all.each {|e| e.set_match}
  end

  def to_s
    "#{authors} #{year}. #{title}."
  end

  # ReferenceComparable
  def author; authors.split(',').first; end
  def type; reference_type; end

  private
  def set_year
    self.year = ::Reference.get_year citation_year
  end

end
