# frozen_string_literal: true

# `GET /llms.txt`: the plain-text guide for programs and AI agents (the same guidance as the API front
# door, `Api::V1::RootController`). A page rather than a file in `public/`, so the part about API keys
# follows `ApiAccess.enabled?` (live or "coming").
class LlmsTxtController < ApplicationController
  skip_before_action :store_location_for_devise

  def show
    render formats: :text, content_type: 'text/plain'
  end
end
