class User < ApplicationRecord
  include Trackable

  UNCONFIRMED_USER_EDIT_LIMIT_COUNT = 5
  UNCONFIRMED_USER_EDIT_LIMIT_PERIOD = 24.hours
  IGNORED_TRACKABLE_TYPES_FOR_UNCONFIRMED_USER_EDIT_LIMIT = %w[Feedback]
  MAX_NEW_REGISTRATIONS_PER_DAY = 20

  has_many :activities, dependent: :restrict_with_error
  has_many :comments, dependent: :restrict_with_error
  has_many :notifications, dependent: :restrict_with_error
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification"

  validates :name, presence: true, uniqueness: true, format: { with: /\A[^<>]*\z/ }

  scope :order_by_name, -> { order(:name) }
  scope :unconfirmed, -> { where(editor: false, helper: false) }
  scope :active, -> { where(deleted: false) }
  scope :non_hidden, -> { where(hidden: false) }

  acts_as_reader
  devise :database_authenticatable, :recoverable, :registerable,
    :rememberable, :trackable, :validatable
  has_paper_trail
  trackable parameters: proc { { user_id: id } }

  # NOTE: Super primitive way of preventing mass registrations.
  def self.too_many_registrations_today?
    where(created_at: 1.day.ago..Time.current).count > MAX_NEW_REGISTRATIONS_PER_DAY
  end

  def active_for_authentication?
    super && !locked?
  end

  def unconfirmed_user_over_edit_limit?
    return unless unconfirmed?
    remaining_edits_for_unconfirmed_user <= 0
  end

  def unconfirmed?
    !(helper? || editor?)
  end

  def remaining_edits_for_unconfirmed_user
    edit_count = activities.
                   where(created_at: UNCONFIRMED_USER_EDIT_LIMIT_PERIOD.ago..Time.current).
                   where.not(trackable_type: IGNORED_TRACKABLE_TYPES_FOR_UNCONFIRMED_USER_EDIT_LIMIT).
                   count
    raise "unconfirmed user #{id} has negative remaining edits" if edit_count > UNCONFIRMED_USER_EDIT_LIMIT_COUNT
    UNCONFIRMED_USER_EDIT_LIMIT_COUNT - edit_count
  end

  def at_least_helper?
    helper? || editor?
  end

  def unread_site_notices
    SiteNotice.unread_by(self)
  end

  def notify_because(reason, attached:, notifier:)
    return if notifier == self
    return if already_notified_for_attached_by_user? attached, notifier

    notifications.create!(reason: reason, attached: attached, notifier: notifier)
  end

  def mark_unseen_notifications_as_seen
    unseen_notifications.find_each { |notification| notification.update(seen: true) }
  end

  private

    # To avoid sending repeated notifications eg when a comment that
    # already mentions a user is edited and saved again.
    def already_notified_for_attached_by_user? attached, mentioner
      notifications.where(notifier: mentioner, attached: attached).exists?
    end
end
