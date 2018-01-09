class Comment < ApplicationRecord
  include FilterableWhere
  include Trackable

  attr_accessor :set_parent_to

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :order_by_date, -> { order(created_at: :desc)._include_associations }
  scope :most_recent, ->(number = 5) { order_by_date.limit(number) }
  scope :_include_associations, -> { includes(:commentable, :user) }

  validates :user, presence: true
  validates :body, presence: true

  after_save { set_parent if set_parent_to.present? }
  after_save :notify_relevant_users

  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  alias_method :commenter, :user # Read-only, for `Comments::NotifyRelevantUsers`.
  has_paper_trail
  tracked on: :create

  def self.build_comment commentable, user, body = ""
    new commentable: commentable, body: body, user: user
  end

  def is_a_reply?
    !parent.nil? || set_parent_to.present?
  end

  private
    def set_parent
      move_to_child_of Comment.find(set_parent_to)
    end

    def notify_relevant_users
      Comments::NotifyRelevantUsers[self]
    end
end
