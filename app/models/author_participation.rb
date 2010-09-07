class AuthorParticipation < ActiveRecord::Base
  belongs_to :source
  belongs_to :author
end
