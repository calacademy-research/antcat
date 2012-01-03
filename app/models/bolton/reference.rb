# coding: UTF-8
class Bolton::Reference < ActiveRecord::Base
  include ReferenceComparable
  set_table_name :bolton_references

  belongs_to :match, :class_name => '::Reference'
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :possible_matches, :through => :matches, :source => :reference

  before_validation :set_year
  before_save :set_key_cache

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
      query_clauses << 'match_status = "unmatchable"' if options[:match_statuses].include? 'unmatchable'
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
    if string == 'unmatchable'
      self.match = nil
      self.match_status = 'unmatchable'
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
    "#{authors} #{citation_year}. #{title}."
  end

  def best_match_similarity
    matches.first && matches.first.similarity
  end

  def possible_matches_with_matched_first
    (possible_matches + [match]).uniq.compact.partition {|m| m == match}.flatten
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

  def self.match_status_unmatchable_count
    where(:match_status => 'unmatchable').count
  end

  # ReferenceComparable
  def author; authors.split(',').first; end
  def type; reference_type; end

  def key
    @key ||= Bolton::ReferenceKey.new authors, citation_year
  end

  def self.set_key_caches
    all.each do |reference|
      reference.set_key_cache
      reference.save!
    end
  end

  def set_key_cache
    self.key_cache = key.to_s :db
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end

  def self.normalize_to_see_if_anything_important_changed string
    return unless string
    original_string = string.dup
    string = string.gsub /<span.*?>.*?<\/span>/, ''
    string = string.gsub /\s/, ''
    if string =~ /<\/?span/
      require 'ruby-debug';debugger;'';
    end
    string
  end

  def self.import_update reference, attributes
    nothing_important_changed = normalize_to_see_if_anything_important_changed(reference.original) == normalize_to_see_if_anything_important_changed(attributes[:original])
    Progress.puts "Changed: #{reference.original}" unless nothing_important_changed
    reference.update_attributes attributes.merge(:import_result => nothing_important_changed ? 'updated_spans_removed' : 'updated')
    Progress.puts "To:      #{attributes[:original]}" unless nothing_important_changed
    Progress.puts unless nothing_important_changed
  end

  def self.import_updated_title reference, attributes
    Progress.puts "Updated title for #{reference}"
    Progress.puts "From: #{reference.title}"
    Progress.puts "To:   #{attributes[:title]}"
    Progress.puts
    reference.update_attributes attributes.merge(:import_result => 'updated_title')
  end

  def self.import_updated_year reference, attributes
    Progress.puts "Updated year for #{reference}"
    Progress.puts "From #{reference.citation_year} to #{attributes[:citation_year]}"
    Progress.puts
    reference.update_attributes attributes.merge(:import_result => 'updated_year')
  end

  def self.import attributes
    attributes[:title] = attributes[:title][0, 255]
    if reference = where(attributes).first
      reference.update_attribute :import_result, 'identical'
    elsif reference = where(:authors => attributes[:authors], :citation_year => attributes[:citation_year], :title => attributes[:title]).first
      import_update reference, attributes
    elsif reference = where(:authors => attributes[:authors], :citation_year => attributes[:citation_year]).first
      import_updated_title reference, attributes
  elsif reference = where(:authors => attributes[:authors], :title => attributes[:title]).first
        import_updated_year reference, attributes
    else
      reference = create! attributes.merge(:import_result => 'added')
    end
    reference
  end

end
