# frozen_string_literal: true

# API requests per minute, for the per-minute limits (see `ApiAccess::Gate`). In the database rather
# than `Rails.cache` (which is not shared reliably between the Puma workers). Old rows are pruned.
class ApiUsageMinute < ApplicationRecord
  # Counts one request and returns the number of requests in that minute, this one included.
  def self.hit minute:, api_key_id:, client:
    sql = sanitize_sql_array([<<~SQL.squish, minute, api_key_id, client])
      INSERT INTO api_usage_minutes (minute, api_key_id, client, requests) VALUES (?, ?, ?, 1)
      ON DUPLICATE KEY UPDATE requests = api_usage_minutes.requests + 1
    SQL
    with_connection { |connection| connection.exec_update(sql, "ApiUsageMinute Hit") }
    where(minute: minute, api_key_id: api_key_id, client: client).pick(:requests).to_i
  end

  def self.prune before:
    where(minute: ...before).delete_all
  end
end
