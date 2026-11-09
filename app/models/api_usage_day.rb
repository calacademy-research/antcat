# frozen_string_literal: true

# API requests, records sent and refused requests (429) per UTC day: one row per key, and one per
# hashed visitor IP for requests without a key (`api_key_id` 0, see `ApiAccess.ip_hash`).
class ApiUsageDay < ApplicationRecord
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

  # Totals per key for the admin page: `{ api_key_id => { today:, last_7_days:, last_30_days:, records:, rejected: } }`
  # (records and refused requests over the last 30 days).
  def self.summary_by_key today: Time.current.utc.to_date
    with_key.where(day: (today - 29.days)..today).group(:api_key_id).pluck(
      :api_key_id,
      Arel.sql(sanitize_sql_array(["SUM(CASE WHEN day = ? THEN requests ELSE 0 END)", today])),
      Arel.sql(sanitize_sql_array(["SUM(CASE WHEN day >= ? THEN requests ELSE 0 END)", today - 6.days])),
      Arel.sql("SUM(requests)"), Arel.sql("SUM(records)"), Arel.sql("SUM(rejected)")
    ).to_h do |api_key_id, today_count, last_7_days, last_30_days, records, rejected|
      counts = {
        today: today_count.to_i,
        last_7_days: last_7_days.to_i,
        last_30_days: last_30_days.to_i,
        records: records.to_i,
        rejected: rejected.to_i
      }
      [api_key_id, counts]
    end
  end

  # Requests without a key, per day: `[[day, visitors, requests, records, rejected], ...]`, newest first.
  def self.no_key_totals days:, today: Time.current.utc.to_date
    without_key.where(day: (today - (days - 1).days)..today).group(:day).order(day: :desc).pluck(
      :day, Arel.sql("COUNT(*)"), Arel.sql("SUM(requests)"), Arel.sql("SUM(records)"), Arel.sql("SUM(rejected)")
    ).map { |day, *counts| [day, *counts.map(&:to_i)] }
  end
end
