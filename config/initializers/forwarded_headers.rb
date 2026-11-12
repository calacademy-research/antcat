# frozen_string_literal: true

# The visitor's address (`request.remote_ip`), scheme and host come from the headers our own nginx
# sets (`X-Forwarded-For`, `X-Forwarded-Proto`, `Host`; see dockerized_app/nginx/default.conf).
# Rack 3 would otherwise prefer the RFC 7239 `Forwarded` header, which nginx does not set, so it
# could only ever hold what a client sent. Read the `X-Forwarded-*` headers only.
Rack::Request.forwarded_priority = [:x_forwarded]
