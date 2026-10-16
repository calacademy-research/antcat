# frozen_string_literal: true

require 'rails_helper'

describe "Content Security Policy" do
  describe "the report-only header" do
    before { create :family }

    it "is sent on HTML pages, with a script nonce and the report endpoint" do
      get root_path

      header = response.headers['Content-Security-Policy-Report-Only']
      expect(header).to include "default-src 'self'"
      expect(header).to match(/script-src [^;]*'nonce-/)
      expect(header).to include "report-uri /csp_reports"
      expect(response.headers['Content-Security-Policy']).to be_nil
    end
  end

  describe "POST /csp_reports" do
    before do
      CspReportsController::RATE_LIMIT_STORE.clear
      allow(Rails.logger).to receive(:warn).and_call_original
    end

    def post_report body, content_type: 'application/csp-report'
      post csp_reports_path, params: body, headers: { 'CONTENT_TYPE' => content_type }
    end

    let(:report_uri_body) do
      {
        'csp-report' => {
          'document-uri' => 'https://www.antcat.org/catalog/429011?secret=1',
          'violated-directive' => 'script-src-elem',
          'effective-directive' => 'script-src-elem',
          'blocked-uri' => 'https://evil.example.com/x.js?token=abc'
        }
      }.to_json
    end

    it "logs one compact line with the page path only and the blocked origin only" do
      post_report report_uri_body

      expect(response).to have_http_status :no_content
      expect(Rails.logger).to have_received(:warn).
        with("CSP violation: directive=script-src-elem blocked=https://evil.example.com page=/catalog/429011")
    end

    it "accepts the Reporting API format" do
      body = [
        {
          'type' => 'csp-violation',
          'body' => {
            'documentURL' => 'https://www.antcat.org/references/1',
            'effectiveDirective' => 'script-src-attr',
            'blockedURL' => 'inline'
          }
        }
      ].to_json
      post_report body, content_type: 'application/reports+json'

      expect(response).to have_http_status :no_content
      expect(Rails.logger).to have_received(:warn).
        with("CSP violation: directive=script-src-attr blocked=inline page=/references/1")
    end

    it "ignores bodies that are not reports" do
      post_report 'not json'

      expect(response).to have_http_status :no_content
      expect(Rails.logger).not_to have_received(:warn).with(/CSP violation/)
    end

    it "does not need a CSRF token" do
      ActionController::Base.allow_forgery_protection = true
      post_report report_uri_body
      expect(response).to have_http_status :no_content
    ensure
      ActionController::Base.allow_forgery_protection = false
    end

    it "is rate limited to 60 requests a minute per IP" do
      60.times { post_report report_uri_body }
      expect(response).to have_http_status :no_content

      post_report report_uri_body
      expect(response).to have_http_status :too_many_requests
    end
  end
end
