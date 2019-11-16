class Comment < ApplicationRecord
  include FilterableWhere
  include Trackable

  attr_accessor :set_parent_to

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :order_by_date, -> { order(created_at: :desc) }
  scope :most_recent, ->(number = 5) { order_by_date.include_associations.limit(number) }
  scope :include_associations, -> { includes(:commentable, :user) }

  validates :user, :body, presence: true

  after_save { set_parent if set_parent_to.present? }

  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  alias_method :commenter, :user # Read-only, for `Comments::NotifyRelevantUsers`.
  has_paper_trail
  trackable

  def self.build_comment commentable, user, body: nil
    new(commentable: commentable, body: body, user: user)
  end

  def a_reply?
    !parent.nil? || set_parent_to.present?
  end

  def notify_relevant_users
    Comments::NotifyRelevantUsers[self]
  end

  private

    def set_parent
      move_to_child_of Comment.find(set_parent_to)
    end
end
