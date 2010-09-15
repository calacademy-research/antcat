class AuthorParticipation < ActiveRecord::Base
  belongs_to :reference
  belongs_to :author
  acts_as_list :scope => :reference
end
