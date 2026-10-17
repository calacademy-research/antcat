# frozen_string_literal: true

# Content Security Policy. See https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# REPORT-ONLY for now: browsers send violations to `/csp_reports` (logged at warn as "CSP violation: ...")
# but nothing is blocked. Before enforcing, fix the inline scripts that are not nonced yet (see PR notes).
#
# What the app loads from other hosts:
# * Google Fonts: Montserrat and Raleway (layout), Droid Sans (`/api_docs`).
# * Google Analytics (`_google_analytics.html.erb`, production only).
# * reCAPTCHA v3 (`RecaptchaHelper`, visitors only on registration and feedback forms).
# * New Relic browser agent (auto-injected by `newrelic_rpm` when browser monitoring is on for the account).
# Reference PDFs on S3 are links/redirects (navigation), not embedded, so they need no source here.

Rails.application.configure do
  google_fonts_css = 'https://fonts.googleapis.com'
  google_fonts_files = 'https://fonts.gstatic.com'
  google_analytics = ['https://www.google-analytics.com', 'https://*.google-analytics.com']
  recaptcha = ['https://www.google.com', 'https://www.gstatic.com', 'https://recaptcha.google.com']
  new_relic_browser = ['https://js-agent.newrelic.com', 'https://*.nr-data.net']

  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.object_src :none
    policy.frame_ancestors :self
    policy.form_action :self
    policy.script_src :self, *google_analytics, *recaptcha, *new_relic_browser
    # `style=` attributes and Turbo's progress bar `<style>` are inline; acceptable for now.
    policy.style_src :self, :unsafe_inline, google_fonts_css
    policy.font_src :self, :data, google_fonts_files
    policy.img_src :self, :data, :https
    policy.connect_src :self, *google_analytics, *recaptcha, *new_relic_browser
    policy.frame_src(*recaptcha)
    policy.report_uri '/csp_reports'
  end

  # Nonce for inline `<script>` tags (`content_security_policy_nonce`, `javascript_tag nonce: true`).
  # Session based (Rails default) so it stays the same across Turbo Drive visits, where the browser
  # keeps the CSP of the first page load. `SecureRandom` covers requests without a session id.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s.presence || SecureRandom.base64(16) }
  # Scripts only: a nonce in `style-src` would make browsers ignore its 'unsafe-inline'.
  config.content_security_policy_nonce_directives = %w[script-src]

  config.content_security_policy_report_only = true
end
