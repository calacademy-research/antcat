# frozen_string_literal: true

require_relative "invalid_records"

namespace :antcat do
  desc "Find all invalid ActiveRecords"
  task invalid_records: [:environment] do
    AntCat::InvalidRecords.call
  end
end
