# frozen_string_literal: true

# Receives Content Security Policy violation reports from browsers and logs one compact line per
# violation. No database writes. Inherits from `ActionController::API` so there is no CSRF check,
# HTTP basic auth (staging) or other `ApplicationController` callbacks on this endpoint.
class CspReportsController < ActionController::API
  MAX_BODY_BYTES = 16.kilobytes
  MAX_REPORTS_PER_REQUEST = 10
  MAX_FIELD_LENGTH = 200
  # Per-process store, so reports never touch the shared app cache.
  RATE_LIMIT_STORE = ActiveSupport::Cache::MemoryStore.new(size: 1.megabyte)

  rate_limit to: 60, within: 1.minute, store: RATE_LIMIT_STORE, with: -> { head :too_many_requests }

  def create
    reports.first(MAX_REPORTS_PER_REQUEST).each do |report|
      Rails.logger.warn "CSP violation: #{format_report(report)}"
    end
    head :no_content
  end

  private

    def reports
      body = request.raw_post
      return [] if body.blank? || body.bytesize > MAX_BODY_BYTES

      parsed = JSON.parse(body)
      if parsed.is_a?(Hash) && parsed['csp-report'].is_a?(Hash) # `report-uri` format.
        [parsed['csp-report']]
      elsif parsed.is_a?(Array) # Reporting API (`report-to`) format.
        parsed.filter_map { |item| item['body'] if item.is_a?(Hash) && item['body'].is_a?(Hash) }
      else
        []
      end
    rescue JSON::ParserError
      []
    end

    def format_report report
      directive = report['effective-directive'] || report['violated-directive'] || report['effectiveDirective']
      blocked = report['blocked-uri'] || report['blockedURL']
      document = report['document-uri'] || report['documentURL']

      "directive=#{clean(directive)} blocked=#{clean(origin_or_keyword(blocked))} page=#{clean(path_only(document))}"
    end

    # Keeps "inline", "eval" etc. as is; reduces URLs to their origin (drops paths and query strings).
    def origin_or_keyword value
      uri = URI.parse(value.to_s)
      uri.host ? "#{uri.scheme}://#{uri.host}" : value
    rescue URI::InvalidURIError
      value
    end

    def path_only value
      URI.parse(value.to_s).path
    rescue URI::InvalidURIError
      nil
    end

    def clean value
      value.to_s.gsub(/[^[:print:]]|\s/, '_').truncate(MAX_FIELD_LENGTH).presence || '-'
    end
end
