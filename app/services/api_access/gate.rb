# frozen_string_literal: true

# Decides whether one API request may go ahead, and counts it (see `ApiAccess`). Used by
# `ApiKeyAccess` (the concern in `Api::ApiController`) only when `ApiAccess.enabled?`.
#
#   gate = ApiAccess::Gate.new(api_key: key_or_nil, ip: request.remote_ip)
#   rejection = gate.admit       # nil, or a Rejection to answer with 429
#   gate.records_per_page        # page size for list routes
#   gate.add_records(n)          # after the answer, records sent
module ApiAccess
  class Gate
    Rejection = Data.define(:limit_name, :limit, :retry_after) do
      def per_minute?
        limit_name == :requests_per_minute
      end
    end

    # Rows of `api_usage_minutes` older than this are deleted, now and then, as new requests come in.
    KEEP_MINUTES = 5
    PRUNE_EVERY_N_REQUESTS = 100

    attr_reader :api_key

    def initialize api_key:, ip:, now: Time.current
      @api_key = api_key
      @ip = ip
      @now = now.utc
    end

    def limits
      @_limits ||= api_key ? api_key.limits : NO_KEY_LIMITS
    end

    # Returns nil when the request may go ahead (and counts it), or a `Rejection` (counted as refused).
    def admit
      if (rejection = daily_rejection)
        count_rejected
        return rejection
      end

      if (rejection = minute_rejection)
        count_rejected
        return rejection
      end

      ApiUsageDay.add day: today, api_key_id: api_key_id, client: client, requests: 1
      api_key&.touch_last_used(@now)
      nil
    end

    # Page size for list routes: the level's records per page, but never more than is left of the
    # daily records limit.
    def records_per_page
      per_page = limits.records_per_page
      return per_page unless limits.records_per_day

      left = limits.records_per_day - usage_today.records
      left.positive? ? [per_page, left].min : per_page
    end

    def add_records count
      return unless count.positive?
      ApiUsageDay.add day: today, api_key_id: api_key_id, client: client, records: count
    end

    def api_key_id
      api_key ? api_key.id : NO_KEY_ID
    end

    # The visitor's IP hash for requests without a key; empty for keys (counted per key).
    def client
      @_client ||= api_key ? "" : ApiAccess.ip_hash(@ip, today)
    end

    private

      def today
        @now.to_date
      end

      def usage_today
        @_usage_today ||= ApiUsageDay.find_by(day: today, api_key_id: api_key_id, client: client) ||
          ApiUsageDay.new(requests: 0, records: 0, rejected: 0)
      end

      def daily_rejection
        if limits.requests_per_day && usage_today.requests >= limits.requests_per_day
          Rejection.new(:requests_per_day, limits.requests_per_day, seconds_until_tomorrow)
        elsif limits.records_per_day && usage_today.records >= limits.records_per_day
          Rejection.new(:records_per_day, limits.records_per_day, seconds_until_tomorrow)
        end
      end

      def minute_rejection
        return unless limits.requests_per_minute

        minute = @now.beginning_of_minute
        ApiUsageMinute.prune(before: minute - KEEP_MINUTES.minutes) if rand(PRUNE_EVERY_N_REQUESTS).zero?
        count = ApiUsageMinute.hit(minute: minute, api_key_id: api_key_id, client: client)
        return if count <= limits.requests_per_minute

        Rejection.new(:requests_per_minute, limits.requests_per_minute, seconds_until(minute + 1.minute))
      end

      def count_rejected
        ApiUsageDay.add day: today, api_key_id: api_key_id, client: client, rejected: 1
      end

      # Days are UTC days.
      def seconds_until_tomorrow
        seconds_until(@now.beginning_of_day + 1.day)
      end

      def seconds_until time
        [(time - @now).ceil, 1].max
      end
  end
end
