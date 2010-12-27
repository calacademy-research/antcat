class Bolton::Reference < ActiveRecord::Base
  include ReferenceComparable
  set_table_name :bolton_references

  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches

  before_validation :set_year

  named_scope :with_confidence, lambda {|confidence| {
    :joins => :matches,
    :conditions => ['confidence = ?', confidence]
  }}

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
