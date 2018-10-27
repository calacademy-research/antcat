# TODO column for `devise :invitable` can be removed from the db.

class User < ApplicationRecord
  include Trackable

  has_many :activities
  has_many :comments
  has_many :notifications, -> { order(id: :desc) }
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification"

  validates :name, presence: true

  scope :order_by_name, -> { order(:name) }
  scope :as_angle_bracketed_emails, -> { all.map(&:angle_bracketed_email).join(", ") }

  acts_as_reader
  devise :database_authenticatable, :recoverable, :registerable,
    :rememberable, :trackable, :validatable
  has_paper_trail
  tracked on: :create, parameters: proc { { user_id: id } }

  def self.current
    RequestStore.store[:current_user]
  end

  def self.current=(user)
    RequestStore.store[:current_user] = user
  end

  # TODO rename db column.
  def superadmin?
    is_superadmin?
  end

  # TODO rename db column.
  def is_editor?
    can_edit?
  end

  def is_at_least_helper?
    is_helper? || is_editor?
  end

  # TODO move to `UserDecorator`.
  def angle_bracketed_email
    %("#{name}" <#{email}>)
  end

  def notify_because(reason, attached:, notifier:)
    return if notifier == self
    return if already_notified_for_attached_by_user? attached, notifier

    Notification.create! user: self, reason: reason, attached: attached, notifier: notifier
  end

  def mark_unseen_notifications_as_seen
    unseen_notifications.update_all seen: true
  end

  # For at.js.
  def mentionable_search_key
    "#{id} #{name} #{email}"
  end

  private

    # To avoid sending repeated notifications eg when a comment that
    # already mentions a user is edited and saved again.
    def already_notified_for_attached_by_user? attached, mentioner
      notifications.where(notifier: mentioner, attached: attached).exists?
    end
end
