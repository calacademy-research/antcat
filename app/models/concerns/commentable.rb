module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :commenters, -> { distinct }, through: :comments, class_name: 'User', source: 'user'
  end
end
