class Bolton::Reference < ActiveRecord::Base
  include ReferenceComparable
  set_table_name :bolton_references

  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches

  before_validation :set_year

  scope :with_possible_matches,
    select('DISTINCT bolton_references.*').
      joins('LEFT OUTER JOIN bolton_matches ON bolton_matches.bolton_reference_id = bolton_references.id').
      where('similarity < 0.80')

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
