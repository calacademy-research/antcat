class Bolton::Reference < ActiveRecord::Base
  belongs_to :reference
  has_many :matches, :class_name => 'Bolton::Match', :foreign_key => :bolton_reference_id
  has_many :references, :through => :matches
  set_table_name :bolton_references
  before_validation :set_year

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end 

  def principal_author_last_name
    authors.split(',').first
  end

  def match ward_reference
    return 0 if reference_type == 'UnknownReference' || ward_reference.type == 'UnknownReference'
    return 0 unless principal_author_last_name == ward_reference.author_names.first.last_name
    return 100 if title == ward_reference.title
    1
  end
end
