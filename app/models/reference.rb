class Reference < ActiveRecord::Base
  has_many :author_participations, :order => :position
  has_many :authors, :through => :author_participations, :order => :position,
           :after_add => :update_authors_string, :after_remove => :update_authors_string
  belongs_to :journal
  belongs_to :source_reference, :polymorphic => true

  searchable do
    text :title
    text :authors_string
    string :authors_string
    string :citation_year
    integer :year
  end

  before_validation :set_year, :strip_newlines, :set_source_url
  before_save :set_authors_string

  validates_presence_of :year, :title
  validates_http_url :source_url, :malformed_url => 'is not in a valid format', :message => 'was not found',
                     :valid_responses => [Net::HTTPSuccess, Net::HTTPRedirection]

  named_scope :sorted_by_author, 
    :select => '`references`.*',
    :joins => 'JOIN author_participations ON reference_id = `references`.id JOIN authors ON author_id = authors.id',
    :conditions => 'author_participations.position = 1',
    :order => 'name ASC'

  def self.do_search string = nil, page = nil
    return all(:order => 'authors_string, citation_year').paginate unless string.present?
    search {
      if string.present?
        if match = string.match(/(\d{4})-(\d{4})/)
          with(:year).between((match[1].to_i)..(match[2].to_i))
        elsif match = string.match(/\d{4}/)
          with(:year).equal_to match[0].to_i
        end
        string.gsub! /#{match[0]}/, '' if match
        keywords string
      end

      order_by :authors_string
      order_by :citation_year
      paginate :page => page
    }.results
  end

  def self.import data
    reference = nil
    return reference if reference = find_duplicate(data)

    create_data = {
      :authors => Author.import(data[:authors]),
      :authors_suffix => data[:authors_suffix],
      :citation_year => data[:citation_year],
      :title => data[:title],
      :cite_code => data[:cite_code],
      :possess => data[:possess],
      :date => data[:date],
      :public_notes => data[:public_notes],
      :taxonomic_notes => data[:taxonomic_notes],
      :editor_notes => data[:editor_notes],
      :source_reference_id => data[:id],
      :source_reference_type => data[:class], 
    }
    case
    when data[:book]
      BookReference.import create_data, data[:book]
    when data[:article]
      ArticleReference.import create_data, data[:article]
    when data[:nested]
      NestedReference.import create_data, data[:nested]
    when data[:unknown]
      UnknownReference.import create_data, data[:unknown]
    end
  end

  def self.find_duplicate data
    possible_duplicates = Reference.all(:conditions => ['title = ? and year = ?', data[:title], get_year(data[:citation_year])])
    possible_duplicates.find do |possible_duplicate|
      data[:authors] == possible_duplicate.authors.map(&:name)
    end 
  end

  def before_destroy
    nester = NestedReference.find_by_nested_reference_id id
    errors.add_to_base "This reference can't be deleted because it's nested in #{nester}" if nester
    nester.nil?
  end

  def make_authors_string
    string = authors.map(&:name).join('; ')
    string << authors_suffix if authors_suffix.present?
    string
  end

  def set_authors_string _ = nil
    self.authors_string = make_authors_string
  end

  def update_authors_string _ = nil
    update_attribute :authors_string, make_authors_string
  end

  def self.add_period_if_necessary string
    return unless string
    return string if string.empty?
    return string + '.' unless string[-1..-1] == '.'
    string
  end

  def set_year
    self.year = self.class.get_year citation_year
  end 
      
  def self.get_year citation_year
    if citation_year.blank?
      nil
    elsif match = citation_year.match(/\["(\d{4})"\]/)
      match[1]
    else
      citation_year.to_i 
    end
  end

  def strip_newlines
    [:title, :public_notes, :editor_notes, :taxonomic_notes].each do |field|
      self[field].gsub! /\n/, ' ' if self[field].present?
    end
  end

  def self.import_hol_source_urls show_progress = false
    HolSourceUrlImporter.new(show_progress).import
  end

  def to_s
    s = ''
    s << "#{authors_string} "
    s << "#{citation_year}. "
    s << "#{id}."
    s
  end

  def set_source_url
    self.source_url = "http://" + source_url if source_url.present? && source_url !~ %r{^http://}
  end

  def hosted_by_us? our_host_name
    return unless source_url
    # cannot figure out how to set the host with Cucumber + Capybara
    source_url =~ Regexp.new(Rails.env.cucumber? ? 'antcat.org' : our_host_name)
  end
end
