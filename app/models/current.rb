# frozen_string_literal: true

# Per-request state, reset by Rails after every request.
class Current < ActiveSupport::CurrentAttributes
  # True only when a signed-in user makes the request (set in `ApplicationController`). "Logged-in only"
  # content such as `{hiddennote ...}` is rendered only then; it is left out of the HTML (not just hidden
  # by CSS) for visitors, and also everywhere this is not set (rake tasks, mailers, the console).
  attribute :signed_in
end
