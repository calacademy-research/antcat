class Comment < ActiveRecord::Base
  include Feed::Trackable
  tracked on: :create

  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  validates :user, presence: true

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  def self.build_comment commentable, user, body = ""
    new commentable: commentable, body: body, user: user
  end
end
