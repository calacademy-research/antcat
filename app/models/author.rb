class Author < ActiveRecord::Base
  has_many :author_participations
  has_many :sources, :through => :author_participations

  named_scope :for_source, lambda { |source|
    {
      :joins => :author_participations,
      :conditions => {:author_participations => {:source_id => source}}
    }
  }

  def self.import data
    data.inject([]) do |authors, author_name|
      authors << find_or_create_by_name(author_name)
    end
  end


end
