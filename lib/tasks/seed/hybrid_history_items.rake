# frozen_string_literal: true

require_relative "hybrid_history_items"

if Rails.env.development? || Rails.env.test?
  namespace :seed do
    desc 'Seeds for hybrid history items'
    task hybrid_history_items: [:environment] do
      Seed::HybridHistoryItems.call
    end

    task hhi: :hybrid_history_items
  end
end
