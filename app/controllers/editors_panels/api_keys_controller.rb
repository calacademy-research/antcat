# frozen_string_literal: true

module EditorsPanels
  # Superadmins: API key registrations and their usage (see `ApiAccess`). Revoke, reactivate, change
  # the level, set per-key limits and a note; CSV of the list. Works whether or not API keys are on.
  class ApiKeysController < ApplicationController
    NO_KEY_DAYS_SHOWN = 14
    CSV_COLUMNS = [
      "id", "name", "email", "institution", "project", "level", "status", "key starts with", "registered",
      "confirmed", "revoked", "last used", "requests today", "requests 7 days", "requests 30 days",
      "records 30 days", "refused (429) 30 days", "requests per minute", "requests per day",
      "records per page", "records per day", "note"
    ]

    before_action :ensure_user_is_superadmin
    before_action :set_api_key, only: [:edit, :update, :revoke, :reactivate]

    def index
      @api_keys = ApiKey.newest_first
      @usage = ApiUsageDay.summary_by_key
      @no_key_totals = ApiUsageDay.no_key_totals(days: NO_KEY_DAYS_SHOWN)

      respond_to do |format|
        format.html
        format.csv do
          send_data api_keys_csv, filename: "antcat-api-keys-#{Time.current.utc.to_date.iso8601}.csv", type: 'text/csv'
        end
      end
    end

    def edit
    end

    def update
      if @api_key.update(api_key_params)
        redirect_to panel_api_keys_path, notice: "API key ##{@api_key.id} was updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def revoke
      @api_key.revoke!
      redirect_to panel_api_keys_path, notice: "API key ##{@api_key.id} was revoked."
    end

    def reactivate
      if @api_key.reactivate!
        redirect_to panel_api_keys_path, notice: "API key ##{@api_key.id} was reactivated."
      else
        redirect_to panel_api_keys_path, alert: "API key ##{@api_key.id} was never confirmed, so it has no key to reactivate."
      end
    end

    private

      def set_api_key
        @api_key = ApiKey.find(params.expect(:id))
      end

      # Blank limit fields mean "the level's value".
      def api_key_params
        permitted = params.expect(api_key: [:level, :note, *ApiKey::LIMIT_ATTRIBUTES])
        ApiKey::LIMIT_ATTRIBUTES.each do |name|
          permitted[name] = permitted[name].presence if permitted.key?(name)
        end
        permitted
      end

      def api_keys_csv
        rows = [CSV_COLUMNS] + @api_keys.map do |api_key|
          usage = @usage.fetch(api_key.id, {})
          [
            api_key.id, api_key.name, api_key.email, api_key.institution, api_key.project, api_key.level,
            api_key.status, api_key.key_prefix, api_key.created_at, api_key.confirmed_at, api_key.revoked_at,
            api_key.last_used_at, usage[:today].to_i, usage[:last_7_days].to_i, usage[:last_30_days].to_i,
            usage[:records].to_i, usage[:rejected].to_i, *ApiKey::LIMIT_ATTRIBUTES.map { api_key.limits.public_send(it) },
            api_key.note
          ]
        end
        rows.map { |row| row.map { csv_cell(it) }.join(",") }.join("\r\n") + "\r\n"
      end

      # Quoted, with a leading apostrophe for text that a spreadsheet would run as a formula: text that
      # starts with =, +, - or @, also after spaces (some spreadsheets skip them), or with a tab or a
      # carriage return.
      def csv_cell value
        text = value.respond_to?(:utc) ? value.utc.to_fs(:db) : value.to_s
        text = "'#{text}" if text.match?(/\A(?:\s*[=+\-@]|[\t\r])/)
        %("#{text.gsub('"', '""')}")
      end
  end
end
