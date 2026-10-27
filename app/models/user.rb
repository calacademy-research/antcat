# frozen_string_literal: true

class User < ApplicationRecord
  include Trackable

  USER_ROLE_FLAGS = [
    HELPER = 'helper',
    EDITOR = 'editor',
    SUPERADMIN = 'superadmin',
    DEVELOPER = 'developer'
  ]

  NAME_MAX_LENGTH = 100
  EMAIL_MAX_LENGTH = 254 # The longest address SMTP allows.
  # Names are public and were shown in emails; a full name never needs a web address.
  NAME_URL_REGEX = %r{://|\bwww\.}i

  UNCONFIRMED_USER_EDIT_LIMIT_COUNT = 5
  UNCONFIRMED_USER_EDIT_LIMIT_PERIOD = 24.hours

  # Not stored in PaperTrail versions at all (`skip:`), since they hold password hashes, tokens and sign-in data.
  # Existing versions can be cleaned with `rake antcat:users:scrub_sensitive_version_data`.
  SKIP_PAPER_TRAIL_COLUMNS = %i[
    current_sign_in_at
    current_sign_in_ip
    encrypted_password
    last_sign_in_at
    last_sign_in_ip
    password_salt
    remember_created_at
    remember_token
    reset_password_sent_at
    reset_password_token
    sign_in_count
  ]

  belongs_to :author, optional: true

  has_many :activities, dependent: :restrict_with_error
  has_many :comments, dependent: :restrict_with_error
  has_many :notifications, dependent: :restrict_with_error
  has_many :unseen_notifications, -> { unseen }, class_name: "Notification"
  has_many :created_paper_trail_versions, -> { base_scope }, class_name: "PaperTrail::Version",
    foreign_key: :whodunnit, dependent: false

  validates :author, uniqueness: true, allow_nil: true
  validates :name, presence: true, uniqueness: { case_sensitive: true }, format: { with: /\A[^<>]*\z/ },
    length: { maximum: NAME_MAX_LENGTH }
  validates :name, format: { without: NAME_URL_REGEX, message: "cannot contain a web address" }
  validates :email, length: { maximum: EMAIL_MAX_LENGTH }

  scope :order_by_name, -> { order(:name) }
  scope :unconfirmed, -> { where(editor: false, helper: false) }
  scope :active, -> { where(deleted: false, locked: false) }
  scope :non_hidden, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }
  scope :deleted_or_locked, -> { where("deleted = TRUE OR locked = TRUE") }

  acts_as_reader
  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable, :validatable
  has_paper_trail skip: SKIP_PAPER_TRAIL_COLUMNS
  has_settings do |s|
    s.key :editing_helpers, defaults: { create_combination: false }
  end
  trackable parameters: proc { { user_id: id } }

  def active_for_authentication?
    super && !locked? && !deleted
  end

  def unconfirmed_user_over_edit_limit?
    return false unless unconfirmed?
    remaining_edits_for_unconfirmed_user <= 0
  end

  def unconfirmed?
    !(helper? || editor?)
  end

  def remaining_edits_for_unconfirmed_user
    edit_count = activities.where(created_at: UNCONFIRMED_USER_EDIT_LIMIT_PERIOD.ago..Time.current).count
    # The count can go over the limit (two edits at the same time, or activities created by other actions).
    [UNCONFIRMED_USER_EDIT_LIMIT_COUNT - edit_count, 0].max
  end

  def at_least_helper?
    helper? || editor?
  end

  def unread_site_notices
    SiteNotice.unread_by(self)
  end

  def mark_all_notifications_as_seen
    unseen_notifications.find_each { |notification| notification.update!(seen: true) }
  end
end
