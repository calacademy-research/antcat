class AuthorParticipation < ActiveRecord::Base
  belongs_to :reference
  belongs_to :author
end
