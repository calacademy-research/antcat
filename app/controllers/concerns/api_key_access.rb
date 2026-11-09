# frozen_string_literal: true

# API keys and usage limits for the `/v1` controllers (see `ApiAccess`). Does nothing while
# `ApiAccess.enabled?` is false.
#
# The key is read from the `X-API-Key` header only. It is never logged: Rails does not log request
# headers, `api_key` is in `filter_parameters`, and the key is not put in any response or email.
module ApiKeyAccess
  extend ActiveSupport::Concern

  included do
    before_action :check_api_access
    after_action :count_api_records
  end

  private

    def check_api_access
      return unless ApiAccess.enabled?

      api_key = nil
      if (sent_key = request.headers[ApiAccess::HEADER]).present?
        api_key = ApiKey.find_active_by_key(sent_key)
        return render_api_key_not_valid unless api_key
      end

      return render_api_key_needed if api_key.nil? && api_list_of_all_records?

      @api_gate = ApiAccess::Gate.new(api_key: api_key, ip: request.remote_ip)
      if (rejection = @api_gate.admit)
        render_api_over_limit rejection
      end
    end

    # The list routes (`index`) have no filters: they page through a whole table with `starts_at`.
    def api_list_of_all_records?
      action_name == 'index'
    end

    def api_records_per_page
      @api_gate ? @api_gate.records_per_page : ApiAccess::DEFAULT_RECORDS_PER_PAGE
    end

    def count_api_records
      return unless @api_gate && response.successful?
      @api_gate.add_records api_records_in_response
    end

    # Lists are JSON arrays; a single record is a JSON object.
    def api_records_in_response
      body = response.body
      return 0 if body.blank?
      return 1 unless body.start_with?('[')

      parsed = JSON.parse(body)
      parsed.is_a?(Array) ? parsed.size : 1
    rescue JSON::ParserError
      0
    end

    def render_api_key_not_valid
      response.headers['WWW-Authenticate'] = %(ApiKey header="#{ApiAccess::HEADER}")
      render status: :unauthorized, json: {
        error: "API key not valid",
        message: "This API key is not valid (unknown or revoked). Get a free key at #{ApiAccess::REGISTER_URL}.",
        get_a_key: ApiAccess::REGISTER_URL,
        contact: ApiAccess::CONTACT
      }
    end

    def render_api_key_needed
      response.headers['WWW-Authenticate'] = %(ApiKey header="#{ApiAccess::HEADER}")
      render status: :unauthorized, json: {
        error: "API key needed",
        message: "Lists of all records (for example /v1/taxa) need a free API key, sent in the " \
                 "#{ApiAccess::HEADER} header. Get one at #{ApiAccess::REGISTER_URL}. " \
                 "Single records (for example /v1/taxa/429011) work without a key.",
        get_a_key: ApiAccess::REGISTER_URL,
        contact: ApiAccess::CONTACT
      }
    end

    def render_api_over_limit rejection
      response.headers['Retry-After'] = rejection.retry_after.to_s
      render status: :too_many_requests, json: {
        error: "Too many requests",
        message: api_over_limit_message(rejection),
        limit: api_limit_text(rejection),
        retry_after_seconds: rejection.retry_after,
        get_a_key: ApiAccess::REGISTER_URL,
        contact: ApiAccess::CONTACT,
        citation: ApiAccess::CITATION
      }
    end

    def api_over_limit_message rejection
      whose = @api_gate.api_key ? "your API key" : "visitors without an API key"
      wait = rejection.per_minute? ? "#{rejection.retry_after} seconds" : "until tomorrow (UTC)"
      more = if @api_gate.api_key
               "For a larger project, write to #{ApiAccess::CONTACT}."
             else
               "For higher limits, get a free API key at #{ApiAccess::REGISTER_URL}. " \
                 "Larger projects: write to #{ApiAccess::CONTACT}."
             end

      "You have reached the limit for #{whose}: #{api_limit_text(rejection)}. Please slow down and wait " \
        "#{wait}. #{more} Please cite AntCat in your work: #{ApiAccess::CITATION}"
    end

    def api_limit_text rejection
      case rejection.limit_name
      when :requests_per_minute then ApiAccess.limit_text(rejection.limit, "request", "a minute")
      when :requests_per_day then ApiAccess.limit_text(rejection.limit, "request", "a day")
      when :records_per_day then ApiAccess.limit_text(rejection.limit, "record", "a day")
      end
    end
end
