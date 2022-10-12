# frozen_string_literal: true

require_relative 'relational_history_items'

if Rails.env.development? || Rails.env.test?
  namespace :seed do
    desc 'Seeds for relational history items'
    task relational_history_items: [:environment] do
      Seed::RelationalHistoryItems.call
    end
    task hi: :relational_history_items
  end
end
