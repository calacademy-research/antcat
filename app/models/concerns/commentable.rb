# frozen_string_literal: true

# Lets a model take comments (issues, feedback, site notices): its comments and the users who commented.
module Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :commenters, -> { distinct }, through: :comments, class_name: 'User', source: 'user'
  end
end
