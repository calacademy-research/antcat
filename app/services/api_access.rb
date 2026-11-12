# frozen_string_literal: true

# Free registered API keys and the usage limits of the AntCat API (`/v1`), decided by Brian Fisher
# 2026-11-08 (design: AntWeb step 6, PRs 7 to 9).
#
# - The whole feature is switched by `Settings.api_keys.enabled` (default off; turn it on in
#   `config/settings/production.secret.yml` and restart). When it is off, the API answers exactly as
#   before: no key check, no counting, 100 records per page.
# - When it is on, every `/v1` request except the front door (`GET /v1`) is counted in the database
#   (`ApiUsageDay`, `ApiUsageMinute`), so the limits hold across both Puma workers.
#   Requests without a key are counted per visitor IP, stored only as a hash made with a salt that
#   changes every day (`.ip_hash`).
# - The key is sent in the `X-API-Key` header only (never in the web address, which ends up in logs).
#   A key that is unknown or revoked gets 401. Lists of all records (`index` actions; none of them
#   have filters, so they can be paged through to the end with `starts_at`) need a key.
# - Over a limit: 429 with `Retry-After` and a JSON message (`ApiAccess::Gate`).
module ApiAccess
  Limits = Data.define(:requests_per_minute, :requests_per_day, :records_per_page, :records_per_day)

  HEADER = 'X-API-Key'
  NO_KEY_ID = 0
  REGISTER_URL = "https://www.antcat.org/api_keys/new"
  CONTACT = "antcat@antcat.org"
  CITATION = "Bolton, B. <year>. An online catalog of the ants of the world. Available from https://antcat.org. (accessed <date>)"

  # Records per page of the list routes when the feature is off (as before the keys).
  DEFAULT_RECORDS_PER_PAGE = 100
  # Upper bounds for per-key values set on the admin page. nginx allows 10 requests a second per IP
  # (`dockerized_app/nginx/default.conf`), so more than 600 a minute would never be reached.
  MAX_RECORDS_PER_PAGE = 1_000
  MAX_REQUESTS_PER_MINUTE = 600

  # `nil` means no limit.
  NO_KEY_LIMITS = Limits.new(
    requests_per_minute: 5, requests_per_day: 50, records_per_page: 25, records_per_day: nil
  )
  REGISTERED_LIMITS = Limits.new(
    requests_per_minute: 60, requests_per_day: 5_000, records_per_page: 100, records_per_day: 50_000
  )
  # Keys are `ApiKey::LEVELS`. Collaborator keys start with the registered limits; Brian sets their
  # own values on the admin page. Admin keys (AntCat's own scripts and checks) have no daily limits.
  LEVEL_LIMITS = {
    'registered' => REGISTERED_LIMITS,
    'collaborator' => REGISTERED_LIMITS,
    'admin' => Limits.new(
      requests_per_minute: MAX_REQUESTS_PER_MINUTE, requests_per_day: nil,
      records_per_page: MAX_RECORDS_PER_PAGE, records_per_day: nil
    )
  }.freeze

  def self.enabled?
    ActiveModel::Type::Boolean.new.cast(Settings.api_keys.enabled) == true
  end

  # A hash of the visitor's IP that cannot be turned back into the IP and cannot be matched across
  # days: the salt is derived from the app's secret and the date, so it is the same in both Puma
  # workers without being stored anywhere.
  def self.ip_hash ip, day
    salt = Rails.application.key_generator.generate_key("api_access ip salt #{day.iso8601}", 32)
    OpenSSL::HMAC.hexdigest('SHA256', salt, ip.to_s)
  end

  # Plain-language description of a set of limits, for the front door, `/llms.txt` and the key page.
  def self.describe limits
    [
      (limit_text(limits.requests_per_minute, "request", "a minute") if limits.requests_per_minute),
      (limit_text(limits.requests_per_day, "request", "a day") if limits.requests_per_day),
      (limit_text(limits.records_per_page, "record", "per page") if limits.records_per_page),
      (limit_text(limits.records_per_day, "record", "a day") if limits.records_per_day)
    ].compact.join(", ")
  end

  # "60 requests a minute", "1 request a day".
  def self.limit_text count, noun, per
    "#{count.to_fs(:delimited)} #{noun.pluralize(count)} #{per}"
  end
end
