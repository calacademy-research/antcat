class Source < ActiveRecord::Base
  has_many :author_participations
  has_many :authors, :through => :author_participations
  belongs_to :issue
end
