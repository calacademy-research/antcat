# frozen_string_literal: true

# A free registered key for the AntCat API (see `ApiAccess`). One row per registration:
#
# 1. The form (`ApiKeysController#create`) saves a `pending` row and emails a confirmation link. The
#    link's token is stored only as a SHA-256 digest (`confirmation_digest`), and is valid for
#    `CONFIRMATION_VALID_FOR`.
# 2. Confirming (`#issue_key!`) makes the key, shows it once, and stores only its SHA-256 digest
#    (`key_digest`) and the first characters (`key_prefix`, for the admin page). Neither the key nor
#    the token can be shown again; a person who loses the key registers again.
#
# Superadmins can revoke and reactivate keys, change the level and set per-key limits
# (`requests_per_minute`, `requests_per_day`, `records_per_page`, `records_per_day`; blank = the
# level's value) on `/panel/api_keys`.
class ApiKey < ApplicationRecord
  LEVELS = [
    REGISTERED = 'registered',
    COLLABORATOR = 'collaborator',
    ADMIN = 'admin'
  ].freeze
  STATUSES = [
    PENDING = 'pending',
    ACTIVE = 'active',
    REVOKED = 'revoked'
  ].freeze
  LIMIT_ATTRIBUTES = [:requests_per_minute, :requests_per_day, :records_per_page, :records_per_day].freeze

  KEY_PREFIX = 'ac_'
  KEY_RANDOM_LENGTH = 40
  KEY_DISPLAY_LENGTH = 10 # "ac_" and the first 7 random characters.
  KEY_MAX_LENGTH = 100 # Longer header values are not looked up.
  CONFIRMATION_VALID_FOR = 24.hours
  LAST_USED_PRECISION = 1.minute # `last_used_at` is written at most once a minute per key.

  NAME_MAX_LENGTH = 255
  EMAIL_MAX_LENGTH = User::EMAIL_MAX_LENGTH
  INSTITUTION_MAX_LENGTH = 255
  PROJECT_MAX_LENGTH = 2_000
  NOTE_MAX_LENGTH = 5_000

  has_many :usage_days, class_name: 'ApiUsageDay', dependent: nil

  # The "I agree to the terms" box of the form; the time is stored in `terms_accepted_at`.
  attribute :terms, :boolean

  strip_attributes only: [:name, :email, :institution, :project, :note]

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }, format: { with: /\A[^<>]*\z/ }
  validates :email, presence: true, length: { maximum: EMAIL_MAX_LENGTH },
    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :institution, length: { maximum: INSTITUTION_MAX_LENGTH }
  validates :project, presence: true, length: { maximum: PROJECT_MAX_LENGTH }
  validates :note, length: { maximum: NOTE_MAX_LENGTH }
  validates :terms, acceptance: { allow_nil: false, message: "must be accepted" }, on: :create
  validates :level, inclusion: { in: LEVELS }
  validates :status, inclusion: { in: STATUSES }
  validates(*LIMIT_ATTRIBUTES, numericality: { only_integer: true, greater_than: 0, allow_nil: true })
  validates :records_per_page, numericality: { less_than_or_equal_to: ApiAccess::MAX_RECORDS_PER_PAGE, allow_nil: true }
  validates :requests_per_minute,
    numericality: { less_than_or_equal_to: ApiAccess::MAX_REQUESTS_PER_MINUTE, allow_nil: true }

  before_validation(on: :create) { self.terms_accepted_at = Time.current if terms }

  scope :newest_first, -> { order(id: :desc) }

  def self.digest value
    OpenSSL::Digest::SHA256.hexdigest(value)
  end

  # The active key sent in the `X-API-Key` header, or nil.
  def self.find_active_by_key key
    key = key.to_s
    return if key.length > KEY_MAX_LENGTH || !key.start_with?(KEY_PREFIX)
    find_by(key_digest: digest(key), status: ACTIVE)
  end

  # The pending registration for a confirmation link that has not expired, or nil.
  def self.find_pending_by_confirmation_token token
    token = token.to_s
    return if token.blank? || token.length > KEY_MAX_LENGTH
    where(status: PENDING, confirmation_sent_at: CONFIRMATION_VALID_FOR.ago..).
      find_by(confirmation_digest: digest(token))
  end

  # Sets a new confirmation token (stored as a digest) and returns it, for the emailed link.
  def new_confirmation_token
    token = SecureRandom.urlsafe_base64(32)
    self.confirmation_digest = self.class.digest(token)
    self.confirmation_sent_at = Time.current
    token
  end

  # Makes the key and returns it; only its digest is saved. Returns nil when this registration was
  # confirmed in the meantime (for example the link opened twice at once).
  def issue_key!
    with_lock do
      next unless status == PENDING

      key = KEY_PREFIX + SecureRandom.base58(KEY_RANDOM_LENGTH)
      update!(
        key_digest: self.class.digest(key), key_prefix: key.first(KEY_DISPLAY_LENGTH),
        status: ACTIVE, confirmed_at: Time.current, confirmation_digest: nil
      )
      key
    end
  end

  def revoke!
    update!(status: REVOKED, revoked_at: Time.current)
  end

  # Only keys that were issued can be reactivated (a pending registration has no key yet).
  def reactivate!
    return false if key_digest.blank?
    update!(status: ACTIVE, revoked_at: nil)
  end

  def active?
    status == ACTIVE
  end

  def revoked?
    status == REVOKED
  end

  # The level's limits, with any per-key values set on the admin page.
  def limits
    level_limits = ApiAccess::LEVEL_LIMITS.fetch(level, ApiAccess::REGISTERED_LIMITS)
    level_limits.with(**LIMIT_ATTRIBUTES.index_with { |name| self[name] || level_limits.public_send(name) })
  end

  def touch_last_used now
    return if last_used_at && last_used_at > now - LAST_USED_PRECISION
    update_column :last_used_at, now
  end
end
