# frozen_string_literal: true

# Counts requests per visitor IP and per email address in `Rails.cache` (shared by the Puma workers),
# for actions that send email or check passwords (sign-in, sign-up, password reset).
#
# The IP is `request.remote_ip`. In production nginx sets the visitor's address from Cloudflare's
# `CF-Connecting-IP` header only for requests that come from Cloudflare's address ranges (see
# `dockerized_app/nginx/default.conf`), so a header sent by a client is never trusted directly.
module RequestThrottle
  extend ActiveSupport::Concern

  private

    # Returns true when this request is over the per-IP or the per-email limit. Both counters are
    # always incremented, so changing the email does not reset the IP counter and vice versa.
    def request_throttled? name, per_ip:, per_email:, within:, email: nil
      email = normalized_throttle_email(email)
      ip_over = over_throttle_limit?("#{name}:ip:#{request.remote_ip}", per_ip, within)
      email_over = email.present? && over_throttle_limit?("#{name}:email:#{email}", per_email, within)
      ip_over || email_over
    end

    def over_throttle_limit? key, limit, within
      count = Rails.cache.increment(key, 1, expires_in: within)
      count.to_i > limit
    end

    def normalized_throttle_email email
      email.to_s.strip.downcase
    end
end
