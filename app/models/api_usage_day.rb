# frozen_string_literal: true

# API requests, records sent and refused requests (429) per UTC day: one row per key, and one per
# hashed visitor IP for requests without a key (`api_key_id` 0, see `ApiAccess.ip_hash`).
class ApiUsageDay < ApplicationRecord
  # Keys of each key's totals in `.summary_by_key`.
  SUMMARY_COUNTS = [:today, :last_7_days, :last_30_days, :records, :rejected]

  belongs_to :api_key, optional: true

  scope :with_key, -> { where.not(api_key_id: ApiAccess::NO_KEY_ID) }
  scope :without_key, -> { where(api_key_id: ApiAccess::NO_KEY_ID) }

  # Adds to the day's counts in one statement (`INSERT ... ON DUPLICATE KEY UPDATE`), so requests in
  # both Puma workers at the same moment are all counted.
  def self.add day:, api_key_id:, client:, requests: 0, records: 0, rejected: 0
    sql = sanitize_sql_array([<<~SQL.squish, day, api_key_id, client, requests, records, rejected, requests, records, rejected])
      INSERT INTO api_usage_days (day, api_key_id, client, requests, records, rejected) VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE requests = api_usage_days.requests + ?, records = api_usage_days.records + ?,
      rejected = api_usage_days.rejected + ?
    SQL
    with_connection { |connection| connection.exec_update(sql, "ApiUsageDay Add") }
  end

  # Counts one request, but only while the day's requests are under `limit`. The check and the count
  # are one statement (`UPDATE ... WHERE requests < limit`), so two requests at the same moment, in
  # either Puma worker, cannot both take the last one. Returns the number of requests counted: 1, or
  # 0 when the limit is reached.
  def self.add_request_under day:, api_key_id:, client:, limit:
    counted = increment_requests_under(day, api_key_id, client, limit)
    return counted if counted.positive?

    # No row yet (the first request of the day), or the limit is reached. Make the row, with nothing in it,
    # then try once more.
    add day: day, api_key_id: api_key_id, client: client
    increment_requests_under(day, api_key_id, client, limit)
  end

  # The number of rows changed: 1 when the request was counted, 0 when not.
  def self.increment_requests_under day, api_key_id, client, limit
    sql = sanitize_sql_array([<<~SQL.squish, day, api_key_id, client, limit])
      UPDATE api_usage_days SET requests = requests + 1
      WHERE day = ? AND api_key_id = ? AND client = ? AND requests < ?
    SQL
    with_connection { |connection| connection.exec_update(sql, "ApiUsageDay Add request under limit") }.to_i
  end
  private_class_method :increment_requests_under

  # Totals per key for the admin page: `{ api_key_id => { today:, last_7_days:, last_30_days:, records:, rejected: } }`
  # (records and refused requests over the last 30 days).
  def self.summary_by_key today: Time.current.utc.to_date
    with_key.where(day: (today - 29.days)..today).group(:api_key_id).pluck(
      :api_key_id,
      Arel.sql(sanitize_sql_array(["SUM(CASE WHEN day = ? THEN requests ELSE 0 END)", today])),
      Arel.sql(sanitize_sql_array(["SUM(CASE WHEN day >= ? THEN requests ELSE 0 END)", today - 6.days])),
      Arel.sql("SUM(requests)"), Arel.sql("SUM(records)"), Arel.sql("SUM(rejected)")
    ).to_h { |api_key_id, *sums| [api_key_id, SUMMARY_COUNTS.zip(sums.map(&:to_i)).to_h] }
  end

  # Requests without a key, per day: `[[day, visitors, requests, records, rejected], ...]`, newest first.
  def self.no_key_totals days:, today: Time.current.utc.to_date
    without_key.where(day: (today - (days - 1).days)..today).group(:day).order(day: :desc).pluck(
      :day, Arel.sql("COUNT(*)"), Arel.sql("SUM(requests)"), Arel.sql("SUM(records)"), Arel.sql("SUM(rejected)")
    ).map { |day, *counts| [day, *counts.map(&:to_i)] }
  end
end
